//
//  CloudKitView.m
//  CloudZone
//
//  Created by Adam Wulf on 9/5/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import "CloudKitView.h"
#import "Constants.h"
#import CloudKitImport

@implementation CloudKitView {
    NSButton *_subscribeButton;
    NSButton *_startTestsButton;
    NSButton *_addRecordButton;
}

- (BOOL)isFlipped
{
    return YES;
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        _startTestsButton = [[NSButton alloc] initWithFrame:NSMakeRect(self.bounds.size.width - 120, 40, 100, 20)];
        [_startTestsButton setButtonType:NSMomentaryPushInButton];
        [_startTestsButton setTitle:@"Start Tests"];
        [_startTestsButton setAutoresizingMask:NSViewMinXMargin | NSViewMaxYMargin];
        [_startTestsButton setTarget:self];
        [_startTestsButton setAction:@selector(startTests)];
        [self addSubview:_startTestsButton];

        _subscribeButton = [[NSButton alloc] initWithFrame:NSMakeRect(self.bounds.size.width - 120, 70, 100, 20)];
        [_subscribeButton setButtonType:NSMomentaryPushInButton];
        [_subscribeButton setTitle:@"Subscribe"];
        [_subscribeButton setAutoresizingMask:NSViewMinXMargin | NSViewMaxYMargin];
        [_subscribeButton setTarget:self];
        [_subscribeButton setAction:@selector(listenForPushNotifications)];
        [self addSubview:_subscribeButton];

        _addRecordButton = [[NSButton alloc] initWithFrame:NSMakeRect(self.bounds.size.width - 120, 100, 100, 20)];
        [_addRecordButton setButtonType:NSMomentaryPushInButton];
        [_addRecordButton setTitle:@"Add Record"];
        [_addRecordButton setAutoresizingMask:NSViewMinXMargin | NSViewMaxYMargin];
        [_addRecordButton setTarget:self];
        [_addRecordButton setAction:@selector(addRecord)];
        [self addSubview:_addRecordButton];
    }

    return self;
}

#pragma mark - Records

- (void)addRecord
{
    CKRecord *addRecord = [[CKRecord alloc] initWithRecordType:@"AllFieldType" recordID:[[CKRecordID alloc] initWithRecordName:[[NSUUID UUID] UUIDString] zoneID:[[CKRecordZone defaultRecordZone] zoneID]]];
    addRecord[@"StringField"] = @"a new record";

    CKModifyRecordsOperation *modOp2 = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[addRecord] recordIDsToDelete:nil];
    modOp2.modifyRecordsCompletionBlock = ^(NSArray *modifiedRecords, NSArray *deletedRecordIDs, NSError *err) {
        NSLog(@"Added a record");
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                CKModifyRecordsOperation* modOp3 = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:nil recordIDsToDelete:@[addRecord.recordID]];
                modOp3.modifyRecordsCompletionBlock = ^(NSArray* modifiedRecords, NSArray* deletedRecordIDs, NSError* err){
                    NSLog(@"deleted the record");
                };
                [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:modOp3];
            });
        });
    };
    [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:modOp2];
}

- (void)startTests
{
    __block NSInteger numberOfCompletedTests = 0;
    __block void (^testCompleted)() = ^{
        numberOfCompletedTests++;
        if(numberOfCompletedTests == 8){
            NSLog(@"*****************************");
            NSLog(@"All %ld tests completed", numberOfCompletedTests);
            NSLog(@"*****************************");
        }else{
            NSLog(@"*****************************");
            NSLog(@"%ld tests completed so far...", numberOfCompletedTests);
            NSLog(@"*****************************");
        }

        if(numberOfCompletedTests == 1){
            [self testCloudKitRecordsWithAllFieldTypes:testCompleted];
        }else if(numberOfCompletedTests == 2){
            [self testCloudKitSubscriptions:testCompleted];
        }else if(numberOfCompletedTests == 3){
            [self testCloudKitOperationAPI:testCompleted];
        }else if(numberOfCompletedTests == 4){
            [self testCloudKitRecordsWithAllFieldTypesWithOperations:testCompleted];
        }else if(numberOfCompletedTests == 5){
            [self testCloudKitRecordConvenienceAPI:testCompleted];
        }else if(numberOfCompletedTests == 6){
            [self testCloudKitZoneConvenienceAPI:testCompleted];
        }else if(numberOfCompletedTests == 7){
            [self testCloudKitAssetsWithOperations:testCompleted];
        }
    };

    [self testImmediateCloudKitAuth:testCompleted];

    //
    // this test is useful to run from the CloudZone
    // app to trigger notifications that can be recieved
    // when AgileCloudZone is listening for push notifications
    //    [self testCreateAndDeleteRecordLoop];
}

#pragma mark - Notification Tests

- (void)testNotificationOperations:(void (^)())completionBlock
{
    //
    // these operations don't have an equivalent web service to use.
    //
    [[NSApplication sharedApplication] registerForRemoteNotificationTypes:NSRemoteNotificationTypeBadge];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CKFetchNotificationChangesOperation* noteChangesOp = [[CKFetchNotificationChangesOperation alloc] init];
        noteChangesOp.notificationChangedBlock = ^(CKNotification *notification){
            CKMarkNotificationsReadOperation* markReadOp = [[CKMarkNotificationsReadOperation alloc] initWithNotificationIDsToMarkRead:@[notification.notificationID]];
            markReadOp.markNotificationsReadCompletionBlock =^(NSArray <CKNotificationID *> * __nullable notificationIDsMarkedRead, NSError * __nullable operationError){
                NSAssert(!operationError, @"The notification was marked as read");
                NSAssert([notificationIDsMarkedRead count], @"The notification was marked as read");

                completionBlock();
            };
            [[CKContainer defaultContainer] addOperation:markReadOp];
        };
        noteChangesOp.fetchNotificationChangesCompletionBlock = ^(CKServerChangeToken *serverChangeToken, NSError *operationError){
            NSAssert(serverChangeToken, @"We received a server change token");
            NSAssert(!operationError, @"No error");
        };
        [[CKContainer defaultContainer] addOperation:noteChangesOp];
    });
}

- (void)listenForPushNotifications
{
    [[[CKContainer defaultContainer] privateCloudDatabase] fetchAllSubscriptionsWithCompletionHandler:^(NSArray<CKSubscription *> *_Nullable subscriptions, NSError *_Nullable error) {
        __block NSArray* subsToDelete = @[];
        [subscriptions enumerateObjectsUsingBlock:^(CKSubscription * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            subsToDelete = [subsToDelete arrayByAddingObject:[obj subscriptionID]];
        }];

        CKModifySubscriptionsOperation* delSubOp = [[CKModifySubscriptionsOperation alloc] initWithSubscriptionsToSave:@[] subscriptionIDsToDelete:subsToDelete];
        delSubOp.modifySubscriptionsCompletionBlock = ^(NSArray* savedSubs, NSArray* deletedSubs, NSError* err){
            NSAssert(!err, @"no error");
#ifdef AGILECLOUDKIT
            CKSubscription* newSub = [[CKSubscription alloc] initWithRecordType:@"AllFieldType" filters:@[] options:CKSubscriptionOptionsFiresOnRecordCreation];
#else
            NSDate* date = [NSDate dateWithTimeInterval:-60.0 * 120 sinceDate:[NSDate date]];
            CKSubscription* newSub = [[CKSubscription alloc] initWithRecordType:@"AllFieldType" predicate:[NSPredicate predicateWithFormat:@"creationDate > %@", date] options:CKSubscriptionOptionsFiresOnRecordDeletion];
#endif
            [[[CKContainer defaultContainer] privateCloudDatabase] saveSubscription:newSub completionHandler:^(CKSubscription *subscription, NSError *error) {
                NSAssert(subscription, @"subscription saved ok");
                NSAssert(!error, @"no error");
                [[NSApplication sharedApplication] registerForRemoteNotificationTypes:NSRemoteNotificationTypeAlert];
            }];
        };
        [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:delSubOp];
    }];
}

#pragma mark - Create and Delete Record Loop

- (void)testCreateAndDeleteRecordLoop
{
    CKRecord *testRecord = [[CKRecord alloc] initWithRecordType:@"AllFieldType"];
    testRecord[@"StringField"] = @"mumble";

    CKModifyRecordsOperation *multiAssetOp = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[testRecord] recordIDsToDelete:nil];
    multiAssetOp.atomic = NO;
    multiAssetOp.modifyRecordsCompletionBlock = ^(NSArray *modifiedRecords, NSArray *deletedRecordIDs, NSError *err) {
        NSAssert([modifiedRecords count], @"a record was created");
        NSAssert(!err, @"no error");
        [NSThread sleepForTimeInterval:4];
        CKRecordID* savedRecordID = [[modifiedRecords firstObject] recordID];
        if(!err){
            [self performSelectorOnMainThread:@selector(testDeleteAndCreateRecordLoop:) withObject:savedRecordID waitUntilDone:NO];
        }else{
            [self performSelectorOnMainThread:@selector(testCreateAndDeleteRecordLoop) withObject:nil waitUntilDone:NO];
        }
    };
    [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:multiAssetOp];
}

- (void)testDeleteAndCreateRecordLoop:(CKRecordID *)recordIDToDelete
{
    CKModifyRecordsOperation *multiAssetOp = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[] recordIDsToDelete:@[recordIDToDelete]];
    multiAssetOp.modifyRecordsCompletionBlock = ^(NSArray *modifiedRecords, NSArray *deletedRecordIDs, NSError *err) {
        NSAssert([deletedRecordIDs count], @"a record was deleted");
        NSAssert(!err, @"no error");
        [NSThread sleepForTimeInterval:4];
        [self performSelectorOnMainThread:@selector(testCreateAndDeleteRecordLoop) withObject:nil waitUntilDone:NO];
    };
    [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:multiAssetOp];
}

#pragma mark - Test Cases

- (void)testImmediateCloudKitAuth:(void (^)())completionBlock
{
    [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus, NSError *error) {
        NSAssert(!error, @"was able to fetch auth status");

        completionBlock();
    }];
}
- (void)testCloudKitRecordsWithAllFieldTypes:(void (^)())completionBlock
{
    CKRecordZone *zone = [[CKRecordZone alloc] initWithZoneName:@"persistentRecordZone"];
    [[[CKContainer defaultContainer] privateCloudDatabase] saveRecordZone:zone completionHandler:^(CKRecordZone *zone, NSError *error) {
        NSAssert(zone, @"saved a zone");
        NSAssert(!error, @"no error");

        CKRecordID* recordID = [[CKRecordID alloc] initWithRecordName:@"7A7730D2-8E25-4175-BCCA-A3565DEF025B" zoneID:zone.zoneID];

        [[[CKContainer defaultContainer] privateCloudDatabase] fetchRecordWithID:recordID completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
            //
            // note, for this test you need to manually create a record with the above ID.
            // the tests will never delete it, but will fetch it to test fetching existing records
            NSAssert(record, @"found a record");
            NSAssert(!error, @"no error");

            NSImage* img = [[NSImage alloc] initWithData:record[@"BytesField"]];
            [CloudKitView saveImage:img atPath:@"/Users/adamwulf/Desktop/foo.png"];

            record[@"StringField"] = @"foobar";
            [[[CKContainer defaultContainer] privateCloudDatabase] saveRecord:record completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
                NSAssert(record, @"saved record with asset");
                NSAssert(!error, @"no error");

                completionBlock();
            }];
        }];
    }];
}

- (void)testCloudKitSubscriptions:(void (^)())completionBlock
{
    [[[CKContainer defaultContainer] privateCloudDatabase] fetchAllSubscriptionsWithCompletionHandler:^(NSArray<CKSubscription *> *_Nullable subscriptions, NSError *_Nullable error) {
        NSAssert(!error, @"was able to fetch all subscriptions");

        NSArray* subsToDelete = @[];
        for (CKSubscription* sub in subscriptions){
            subsToDelete = [subsToDelete arrayByAddingObject:sub.subscriptionID];
        }

        // delete all subscriptions
        CKModifySubscriptionsOperation* delSubOp = [[CKModifySubscriptionsOperation alloc] initWithSubscriptionsToSave:@[] subscriptionIDsToDelete:subsToDelete];
        delSubOp.modifySubscriptionsCompletionBlock = ^(NSArray* savedSubs, NSArray* deletedSubs, NSError* err){
            NSAssert([deletedSubs count] == [subsToDelete count], @"deleted the subscription");
            NSAssert(!err, @"no error");
#ifdef AGILECLOUDKIT
            CKSubscription* newSub = [[CKSubscription alloc] initWithRecordType:@"AllFieldType" filters:@[] options:CKSubscriptionOptionsFiresOnRecordUpdate];
#else
            CKSubscription* newSub = [[CKSubscription alloc] initWithRecordType:@"AllFieldType" predicate:[NSPredicate predicateWithFormat:@"StringField='asdf'"] options:CKSubscriptionOptionsFiresOnRecordUpdate];
#endif
            [[[CKContainer defaultContainer] privateCloudDatabase] saveSubscription:newSub completionHandler:^(CKSubscription *subscription, NSError *error) {
                NSAssert(subscription, @"saved ok");
                NSAssert(!error, @"no error");

                [[[CKContainer defaultContainer] privateCloudDatabase] fetchAllSubscriptionsWithCompletionHandler:^(NSArray<CKSubscription *> *_Nullable subscriptions, NSError *_Nullable error) {
                    NSAssert([subscriptions count], @"can fetch subscriptions");
                    NSAssert(!error, @"no error");

                    CKSubscription* currSub = [subscriptions firstObject];
                    if(currSub){
                        [[[CKContainer defaultContainer] privateCloudDatabase] deleteSubscriptionWithID:currSub.subscriptionID completionHandler:^(NSString *subscriptionID, NSError *error) {
                            NSAssert(subscriptionID, @"deleted ok");
                            NSAssert(!error, @"no error");

                            [[[CKContainer defaultContainer] privateCloudDatabase] deleteSubscriptionWithID:newSub.subscriptionID completionHandler:^(NSString *subscriptionID, NSError *error) {
                                NSAssert(subscriptionID, @"deleted ok");
                                NSAssert(!error, @"no error");
                                [self _testCloudKitSubscriptionsAfterDelete:completionBlock];
                            }];
                        }];
                    }else{
                        [self _testCloudKitSubscriptionsAfterDelete:completionBlock];
                    }
                }];
            }];
        };
        [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:delSubOp];
    }];
}


- (void)_testCloudKitSubscriptionsAfterDelete:(void (^)())completionBlock
{
    // create subscription for any update on our persistent record
    CKRecordZone *zone = [[CKRecordZone alloc] initWithZoneName:@"persistentRecordZone"];
#ifdef AGILECLOUDKIT
    NSArray *filters = @[[[CKFilter alloc] initWithComparator:CK_EQUALS fieldName:@"StringField" fieldType:@"STRING" fieldValue:@"test string"]];
    CKReference *ref = [[CKReference alloc] initWithRecordID:[[CKRecordID alloc] initWithRecordName:@"foobar"] action:CKReferenceActionNone];
    filters = @[[[CKFilter alloc] initWithComparator:CK_EQUALS fieldName:@"ReferenceField" fieldType:@"REFERENCE" fieldValue:ref]];
    CKSubscription *sub = [[CKSubscription alloc] initWithRecordType:@"AllFieldType" filters:filters options:CKSubscriptionOptionsFiresOnRecordCreation];
#else
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"StringField = 'test string'"];
    CKSubscription *sub = [[CKSubscription alloc] initWithRecordType:@"AllFieldType" predicate:predicate options:CKSubscriptionOptionsFiresOnRecordCreation];
#endif
    sub.notificationInfo = [[CKNotificationInfo alloc] init];
    sub.notificationInfo.alertBody = @"foobar alert";
    sub.notificationInfo.soundName = @"mySound";
    sub.zoneID = zone.zoneID;

    [[[CKContainer defaultContainer] privateCloudDatabase] saveSubscription:sub completionHandler:^(CKSubscription *subscription, NSError *error) {
        NSAssert(subscription, @"subscription saved");
        NSAssert(!error, @"no error");

        [[[CKContainer defaultContainer] privateCloudDatabase] fetchAllSubscriptionsWithCompletionHandler:^(NSArray<CKSubscription *> * _Nullable subscriptions, NSError * _Nullable error) {
            NSAssert([subscriptions count], @"subscription saved");
            NSAssert(!error, @"no error");

            CKSubscription* existingSub = [subscriptions firstObject];
            existingSub.notificationInfo = nil;

#ifdef AGILECLOUDKIT
            CKSubscription* newSub = [[CKSubscription alloc] initWithRecordType:@"AllFieldType" filters:@[] options:CKSubscriptionOptionsFiresOnRecordUpdate];
#else
            CKSubscription* newSub = [[CKSubscription alloc] initWithRecordType:@"AllFieldType" predicate:[NSPredicate predicateWithFormat:@"StringField='asdf'"] options:CKSubscriptionOptionsFiresOnRecordUpdate];
#endif
            CKModifySubscriptionsOperation* addSubOp = [[CKModifySubscriptionsOperation alloc] initWithSubscriptionsToSave:@[newSub, existingSub] subscriptionIDsToDelete:@[]];
            addSubOp.modifySubscriptionsCompletionBlock = ^(NSArray* savedSubs, NSArray* deletedSubs, NSError* err){
                NSAssert([savedSubs count] == 2, @"saved both subs");
                NSAssert(!existingSub.notificationInfo.alertBody, @"no notification info for the modified sub");
                NSAssert(!error, @"no error");

                CKModifySubscriptionsOperation* delSubOp = [[CKModifySubscriptionsOperation alloc] initWithSubscriptionsToSave:@[] subscriptionIDsToDelete:@[newSub.subscriptionID]];
                delSubOp.modifySubscriptionsCompletionBlock = ^(NSArray* savedSubs, NSArray* deletedSubs, NSError* err){
                    NSAssert([deletedSubs count] == 1, @"deleted the subscription");

                    completionBlock();
                };
                [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:delSubOp];
            };
            [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:addSubOp];
        }];
    }];
}

- (void)testCloudKitAssetsWithOperations:(void (^)())completionBlock
{
    CKRecordZone *zone = [[CKRecordZone alloc] initWithZoneName:@"persistentRecordZone"];
    NSString *recordWithAsset = @"A4A40E35-66D0-4D9E-ACD0-F34D04DF0F69";
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:recordWithAsset zoneID:zone.zoneID];

    __block CKRecord *fetchedRecordWithAsset;
    CKFetchRecordsOperation *fetchOp = [[CKFetchRecordsOperation alloc] initWithRecordIDs:@[recordID]];
    fetchOp.perRecordProgressBlock = ^(CKRecordID *recordID, double progress) {
        NSLog(@"fetch record progress: %.2f %@", progress, recordID);
    };
    fetchOp.perRecordCompletionBlock = ^(CKRecord *record, CKRecordID *recordID, NSError *error) {
        NSAssert(!error, @"no error");
        NSLog(@"per record complete: %@", record.recordID);
        NSLog(@" - : %@", [record[@"AssetField"] fileURL]);
    };
    fetchOp.fetchRecordsCompletionBlock = ^(NSDictionary /* CKRecordID * -> CKRecord */ *recordsByRecordID, NSError *operationError) {
        NSAssert([[recordsByRecordID allKeys] count], @"can fetch records");
        NSAssert(!operationError, @"no error");

        fetchedRecordWithAsset = [[recordsByRecordID allValues] firstObject];
        CKModifyRecordsOperation *recordWithAssetOp = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[fetchedRecordWithAsset] recordIDsToDelete:nil];
        recordWithAssetOp.modifyRecordsCompletionBlock = ^(NSArray *modifiedRecords, NSArray *deletedRecordIDs, NSError *err) {
            NSAssert([modifiedRecords count], @"saved a record");
            NSAssert(!err, @"no error");

            // update the asset
            NSURL *fileURL = [[NSBundle mainBundle] URLForImageResource:@"kitten.jpg"];
            fetchedRecordWithAsset[@"AssetField"] = [[CKAsset alloc] initWithFileURL:fileURL];
            CKModifyRecordsOperation *recordWithAssetOp = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[fetchedRecordWithAsset] recordIDsToDelete:nil];
            recordWithAssetOp.modifyRecordsCompletionBlock = ^(NSArray *modifiedRecords, NSArray *deletedRecordIDs, NSError *err) {
                NSAssert([modifiedRecords count], @"saved a record");
                NSAssert(!err, @"no error");

                CKAsset* asset1 = [[CKAsset alloc] initWithFileURL:[[NSBundle mainBundle] URLForImageResource:@"kitten.jpg"]];
                CKAsset* asset2 = [[CKAsset alloc] initWithFileURL:[[NSBundle mainBundle] URLForImageResource:@"otherkitten.jpg"]];

                CKRecord* recordWithMultipleAssets = [[CKRecord alloc] initWithRecordType:@"AllFieldType" zoneID:zone.zoneID];
                recordWithMultipleAssets[@"AssetListField"] = @[asset1, asset2];

                CKModifyRecordsOperation *multiAssetOp = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[recordWithMultipleAssets] recordIDsToDelete:nil];
                multiAssetOp.modifyRecordsCompletionBlock = ^(NSArray *modifiedRecords, NSArray *deletedRecordIDs, NSError *err) {
                    NSAssert([modifiedRecords count], @"saved record");
                    NSAssert(!err, @"no error");

                    completionBlock();
                };
                [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:multiAssetOp];
            };
            [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:recordWithAssetOp];
        };
        [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:recordWithAssetOp];
    };
    [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:fetchOp];
}


- (void)testCloudKitRecordsWithAllFieldTypesWithOperations:(void (^)())completionBlock
{
    CKRecordZone *zone = [[CKRecordZone alloc] initWithZoneName:@"persistentRecordZone"];
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:@"7A7730D2-8E25-4175-BCCA-A3565DEF025B" zoneID:zone.zoneID];
    CKRecordID *missingRecordID = [[CKRecordID alloc] initWithRecordName:@"missingRecord" zoneID:zone.zoneID];

    CKFetchRecordsOperation *fetchOp = [[CKFetchRecordsOperation alloc] initWithRecordIDs:@[recordID, missingRecordID]];
    fetchOp.perRecordProgressBlock = ^(CKRecordID *recordID, double progress) {
        NSLog(@"fetch record progress: %.2f %@", progress, recordID);
    };
    fetchOp.perRecordCompletionBlock = ^(CKRecord *record, CKRecordID *recordID, NSError *error) {
        if([recordID isEqual:missingRecordID] && !error){
            NSAssert(error, @"missing record should have error");
        }else if(![recordID isEqual:missingRecordID] && error){
            NSAssert(!error, @"shouldn't have error for existing record");
        }
        NSLog(@"per record complete: %@", record.recordID);
    };
    fetchOp.fetchRecordsCompletionBlock = ^(NSDictionary /* CKRecordID * -> CKRecord */ *recordsByRecordID, NSError *operationError) {
        NSAssert([recordsByRecordID count], @"something was fetched");
        NSAssert(operationError, @"(expected error) partial error b/c of missing record");

        CKRecord* record = [[recordsByRecordID allValues] firstObject];
        record[@"StringField"] = @"jumble";
        record[@"IntField"] = @(NO);

        CKModifyRecordsOperation* modOp = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[record] recordIDsToDelete:nil];
        modOp.modifyRecordsCompletionBlock = ^(NSArray* modifiedRecords, NSArray* deletedRecordIDs, NSError* err){
            NSAssert([modifiedRecords count], @"saved records");
            NSAssert(!err, @"no error");

            CKRecord* addRecord = [[CKRecord alloc] initWithRecordType:@"AllFieldType" recordID:[[CKRecordID alloc] initWithRecordName:[[NSUUID UUID]UUIDString] zoneID:record.recordID.zoneID]];
            addRecord[@"StringField"] = @"a new record";

            CKModifyRecordsOperation* modOp2 = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[addRecord] recordIDsToDelete:nil];
            modOp2.modifyRecordsCompletionBlock = ^(NSArray* modifiedRecords, NSArray* deletedRecordIDs, NSError* err){
                NSAssert([modifiedRecords count], @"saved record");
                NSAssert(!err, @"no error");

                CKFetchRecordChangesOperation* recordChangesOperation = [[CKFetchRecordChangesOperation alloc] initWithRecordZoneID:record.recordID.zoneID previousServerChangeToken:nil];
                recordChangesOperation.recordChangedBlock = ^(CKRecord* record){
                    NSLog(@" - was changed %@", [record recordID]);
                };
                recordChangesOperation.recordWithIDWasDeletedBlock = ^(CKRecordID* recordID){
                    NSLog(@" - was deleted %@", recordID);
                };
                recordChangesOperation.fetchRecordChangesCompletionBlock = ^(CKServerChangeToken* token, NSData* notUsed, NSError* opErr){
                    NSAssert(token, @"token for changed records");
                    NSAssert(!opErr, @"no error");

                    CKRecord* hydratedRecord = [[CKRecord alloc] initWithRecordType:addRecord.recordType recordID:addRecord.recordID];
                    hydratedRecord[@"StringField"] = @"modified record";
                    CKModifyRecordsOperation* modOp3 = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[hydratedRecord] recordIDsToDelete:nil];
                    modOp3.savePolicy = CKRecordSaveAllKeys;
                    modOp3.modifyRecordsCompletionBlock = ^(NSArray* modifiedRecords, NSArray* deletedRecordIDs, NSError* err){
                        NSAssert([modifiedRecords count], @"record is modified");
                        NSAssert(!err, @"no error");

                        CKModifyRecordsOperation* modOp4 = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:nil recordIDsToDelete:@[addRecord.recordID]];
                        modOp4.modifyRecordsCompletionBlock = ^(NSArray* modifiedRecords, NSArray* deletedRecordIDs, NSError* err){
                            NSAssert([deletedRecordIDs count], @"deleted a record");
                            NSAssert(!err, @"no error");

                            CKModifyRecordsOperation* modOp5 = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:@[addRecord] recordIDsToDelete:nil];
                            modOp5.perRecordProgressBlock = ^(CKRecord *record, double progress){
                                NSLog(@" - %@ %.2f", [record recordID], progress);
                            };
                            modOp5.perRecordCompletionBlock = ^(CKRecord *record, NSError *error){
                                NSAssert(record, @"can't save a deleted record");
                                NSAssert(error, @"expected error");
                                NSLog(@" - %@ %@", [record recordID], err);
                            };
                            modOp5.modifyRecordsCompletionBlock = ^(NSArray* modifiedRecords, NSArray* deletedRecordIDs, NSError* err){
                                NSAssert(![modifiedRecords count], @"can't save a deleted record");
                                NSAssert(err, @"expected error");

                                CKFetchRecordChangesOperation* nextChangesOperation = [[CKFetchRecordChangesOperation alloc] initWithRecordZoneID:record.recordID.zoneID previousServerChangeToken:token];
                                nextChangesOperation.recordChangedBlock = ^(CKRecord* record){
                                    NSLog(@" - was changed %@", [record recordID]);
                                };
                                nextChangesOperation.recordWithIDWasDeletedBlock = ^(CKRecordID* recordID){
                                    NSLog(@" - was deleted %@", recordID);
                                };
                                nextChangesOperation.fetchRecordChangesCompletionBlock = ^(CKServerChangeToken* token, NSData* notUsed, NSError* opErr){
                                    NSAssert(token, @"record change token");
                                    NSAssert(!opErr, @"no error");

                                    completionBlock();
                                };
                                [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:nextChangesOperation];
                            };
                            [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:modOp5];
                        };
                        [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:modOp4];
                    };
                    [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:modOp3];
                };
                [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:recordChangesOperation];
            };
            [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:modOp2];
        };
        [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:modOp];
    };
    [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:fetchOp];
}


- (void)testCloudKitRecordConvenienceAPI:(void (^)())completionBlock
{
    NSLog(@"=============================");
    NSLog(@"testCloudKitRecordConvenienceAPI");
    NSLog(@"=============================");

    NSLog(@"Fetching all zones");

    [[[CKContainer containerWithIdentifier:@"iCloud.com.agilebits.CloudZone"] privateCloudDatabase] fetchAllRecordZonesWithCompletionHandler:^(NSArray *zones, NSError *error) {
        NSAssert([zones count], @"can fetch zones");
        NSAssert(!error, @"no error");
    }];

    [[[CKContainer defaultContainer] privateCloudDatabase] fetchAllRecordZonesWithCompletionHandler:^(NSArray *zones, NSError *error) {
        CKRecordID* recordID = [[CKRecordID alloc] initWithRecordName:@"missingRecordID"];

        [[[CKContainer defaultContainer] privateCloudDatabase] fetchRecordWithID:recordID completionHandler:^(CKRecord *record, NSError *error) {
            NSAssert(error && error.code == CKErrorUnknownItem, @"operation completed with expected error");
            NSLog(@"error (expected): %@", error);
        }];

        CKRecordZone* zone = [[CKRecordZone alloc] initWithZoneName:@"testRecordZone"];
        [[[CKContainer defaultContainer] privateCloudDatabase] saveRecordZone:zone completionHandler:^(CKRecordZone *zone, NSError *error) {
            NSAssert(zone, @"saved a zone");
            NSAssert(!error, @"operation completed without error");

            CKRecordID* recordID = [[CKRecordID alloc] initWithRecordName:[[NSUUID UUID] UUIDString] zoneID:zone.zoneID];
            CKRecord* recordToSave = [[CKRecord alloc] initWithRecordType:@"SampleRecordType" recordID:recordID];
            recordToSave[@"myfield"] = @"foobar";
            recordToSave[@"otherfield"] = @"mumble";
            [[[CKContainer defaultContainer] privateCloudDatabase] saveRecord:recordToSave completionHandler:^(CKRecord *originalRecord, NSError *error) {
                NSAssert(originalRecord, @"record exists");
                NSAssert(originalRecord == recordToSave, @"record matches input");
                NSAssert(!error, @"no error");

                originalRecord[@"myfield"] = @"foobar2";

                NSAssert([originalRecord.changedKeys count] == 1, @"all changed keys are gone");
                [[[CKContainer defaultContainer] privateCloudDatabase] saveRecord:originalRecord completionHandler:^(CKRecord *record, NSError *error) {
                    NSAssert(record, @"record updated");
                    NSAssert(record == originalRecord, @"record is the same");
                    NSAssert([record.changedKeys count] == 0, @"all changed keys are gone");

                    [[[CKContainer defaultContainer] privateCloudDatabase] fetchRecordWithID:record.recordID completionHandler:^(CKRecord *record, NSError *error) {
                        NSAssert(record, @"found record just fine");
                        NSAssert(!error, @"no error");
                        [[[CKContainer defaultContainer] privateCloudDatabase] deleteRecordWithID:record.recordID completionHandler:^(CKRecordID *recordID, NSError *error) {
                            NSAssert(recordID, @"deleted record");
                            NSAssert(!error, @"no error");

                            [[[CKContainer defaultContainer] privateCloudDatabase] deleteRecordZoneWithID:zone.zoneID completionHandler:^(CKRecordZoneID *zoneID, NSError *error) {
                                NSAssert(zoneID, @"zone deleted");
                                NSAssert(!error, @"no error");
                                NSLog(@"zone deleted: %@", zoneID);

                                completionBlock();
                            }];
                        }];
                    }];
                }];
            }];
        }];
    }];
}

- (void)testCloudKitZoneConvenienceAPI:(void (^)())completionBlock
{
    NSLog(@"=============================");
    NSLog(@"testCloudKitZoneConvenienceAPI");
    NSLog(@"=============================");

    NSLog(@"Fetching all zones");
    [[[CKContainer defaultContainer] privateCloudDatabase] fetchAllRecordZonesWithCompletionHandler:^(NSArray *zones, NSError *error) {
        NSAssert([zones count], @"found zones");
        NSAssert(!error, @"no error");

        CKRecordZone* zone = [[CKRecordZone alloc] initWithZoneName:@"customZoneName"];
        [[[CKContainer defaultContainer] privateCloudDatabase] saveRecordZone:zone completionHandler:^(CKRecordZone *zone, NSError *error) {
            NSAssert(zone, @"saved a zone");
            NSAssert(!error, @"no error");

            [[[CKContainer defaultContainer] privateCloudDatabase] fetchRecordZoneWithID:zone.zoneID completionHandler:^(CKRecordZone *zone, NSError *error) {
                NSAssert(zone, @"fetch a zone");
                NSAssert(!error, @"no error");

                [[[CKContainer defaultContainer] privateCloudDatabase] deleteRecordZoneWithID:zone.zoneID completionHandler:^(CKRecordZoneID *zoneID, NSError *error) {
                    NSAssert(zoneID, @"deleted a zone");
                    NSAssert(!error, @"no error");

                    [[[CKContainer defaultContainer] privateCloudDatabase] fetchRecordZoneWithID:zone.zoneID completionHandler:^(CKRecordZone *zone, NSError *error) {
                        NSAssert(!zone, @"couldn't fetch deleted zone");
                        NSAssert(error, @"operation completed with expected error");

                        completionBlock();
                    }];
                }];
            }];
        }];
    }];
}


- (void)testCloudKitOperationAPI:(void (^)())completionBlock
{
    NSLog(@"=============================");
    NSLog(@"cloudKitOperationAPI");
    NSLog(@"=============================");

    NSLog(@"Fetching all zones");
    CKFetchRecordZonesOperation *op = [CKFetchRecordZonesOperation fetchAllRecordZonesOperation];
    op.fetchRecordZonesCompletionBlock = ^(NSDictionary *recordZonesByZoneID, NSError *operationError) {
        NSAssert([[recordZonesByZoneID allKeys] count], @"can fetch zones");
        NSAssert(!operationError, @"operation completed without error");

        CKRecordZone* zoneToSave = [[CKRecordZone alloc] initWithZoneName:@"customZoneName"];
        CKModifyRecordZonesOperation* modOp = [[CKModifyRecordZonesOperation alloc] initWithRecordZonesToSave:@[zoneToSave]
                                                                                        recordZoneIDsToDelete:@[]];
        modOp.modifyRecordZonesCompletionBlock = ^(NSArray *savedRecordZones, NSArray *deletedRecordZoneIDs, NSError *operationError){
            NSAssert([savedRecordZones count], @"modified record zones");
            NSAssert(!operationError, @"operation completed without error");
            NSLog(@"saved zones ok");

            CKFetchRecordZonesOperation* fetchOp = [[CKFetchRecordZonesOperation alloc] initWithRecordZoneIDs:@[zoneToSave.zoneID]];
            fetchOp.fetchRecordZonesCompletionBlock = ^(NSDictionary * recordZonesByZoneID, NSError * operationError){
                NSAssert([[recordZonesByZoneID allKeys] count], @"can fetch zones");
                NSAssert(!operationError, @"operation completed without error");
                NSLog(@"fetch zones ok");

                CKModifyRecordZonesOperation* delOp = [[CKModifyRecordZonesOperation alloc] initWithRecordZonesToSave:@[]
                                                                                                recordZoneIDsToDelete:@[zoneToSave.zoneID]];
                delOp.modifyRecordZonesCompletionBlock = ^(NSArray *savedRecordZones, NSArray *deletedRecordZoneIDs, NSError *operationError){
                    NSAssert([deletedRecordZoneIDs count], @"zone is deleted");
                    NSAssert(!operationError, @"operation completed without error");
                    NSLog(@"modify zones ok");

                    CKFetchRecordZonesOperation* errOp = [[CKFetchRecordZonesOperation alloc] initWithRecordZoneIDs:@[zoneToSave.zoneID]];
                    errOp.fetchRecordZonesCompletionBlock = ^(NSDictionary * recordZonesByZoneID, NSError * operationError){
                        NSAssert(![[recordZonesByZoneID allKeys] count], @"didn't return any zones");
                        NSAssert(operationError, @"operation completed with expected error");
                        NSLog(@"fetch zones ok");

                        completionBlock();
                    };
                    [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:errOp];
                };
                [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:delOp];
            };
            [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:fetchOp];
        };
        [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:modOp];
    };
    [[[CKContainer defaultContainer] privateCloudDatabase] addOperation:op];
}


+ (void)saveImage:(NSImage *)image atPath:(NSString *)path
{
    CGImageRef cgRef = [image CGImageForProposedRect:NULL
                                             context:nil
                                               hints:nil];
    NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
    [newRep setSize:[image size]]; // if you want the same resolution
    NSData *pngData = [newRep representationUsingType:NSPNGFileType properties:@{}];
    [pngData writeToFile:path atomically:YES];
}
@end
