//
//  CKModifyRecordsOperation.m
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits Inc. All rights reserved.
//

#import <AgileCloudKit/AgileCloudKit.h>
#import "CKDatabaseOperation_Private.h"
#import "CKMediator_Private.h"
#import "NSArray+AgileMap.h"
#import "CKRecord+AgileDictionary.h"
#import "CKRecordID+AgileDictionary.h"
#import "CKRecordZoneID+AgileDictionary.h"
#import "CKRecord_Private.h"
#import "CKDatabase_Private.h"

@implementation CKModifyRecordsOperation

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}


- (instancetype)initWithRecordsToSave:(NSArray *)records recordIDsToDelete:(NSArray *)recordIDs
{
    if (self = [self init]) {
        _savePolicy = CKRecordSaveIfServerRecordUnchanged;
        _recordsToSave = records;
        _recordIDsToDelete = recordIDs;
        _atomic = YES;
    }
    return self;
}


- (void)start
{
    [self setExecuting:YES];

    if ([_recordIDsToDelete count] || [_recordsToSave count]) {
        CKRecordZoneID *zoneID = [[_recordIDsToDelete firstObject] zoneID];
        if (!zoneID) {
            zoneID = [[[_recordsToSave firstObject] recordID] zoneID];
        }

        NSMutableDictionary *savedRecordIDToRecord = [NSMutableDictionary dictionary];


        NSArray *ops = @[];
        ops = [ops arrayByAddingObjectsFromArray:[_recordIDsToDelete agile_mapUsingBlock:^id(id obj, NSUInteger idx) {
            return @{ @"operationType" : @"forceDelete",
                      @"record" : [obj asAgileDictionary] };
        }]];


        ops = [ops arrayByAddingObjectsFromArray:[_recordsToSave agile_mapUsingBlock:^id(id obj, NSUInteger idx) {

            [savedRecordIDToRecord setObject:obj forKey:[obj recordID]];

            NSArray* uploadErrors = [obj synchronouslyUploadAssetsIntoDatabase:self.database];

            if([uploadErrors count]){
                if(self.perRecordCompletionBlock){
                    self.perRecordCompletionBlock(obj, [uploadErrors firstObject]);
                }
                return nil;
            }

            NSDictionary* recordDic = [obj asAgileDictionary];
            NSString* opType = recordDic[@"recordChangeTag"] ? @"update" : @"create";
            if(self.savePolicy == CKRecordSaveAllKeys){
                opType = @"forceUpdate";
            }
            return @{ @"operationType" : opType,
                      @"record" : recordDic };
        }]];

        NSDictionary *requestDictionary = @{ @"operations": ops,
                                             @"zoneID": @{@"zoneName": zoneID.zoneName},
                                             @"atomic": @(_atomic) };

        [self.database sendPOSTRequestTo:@"records/modify" withJSON:requestDictionary completionHandler:^(id jsonResponse, NSError *error) {
            NSMutableArray* savedRecords = [NSMutableArray array];
            NSMutableArray* deletedRecords = [NSMutableArray array];
            NSMutableDictionary* partialFailures = [NSMutableDictionary dictionary];

            if([jsonResponse isKindOfClass:[NSDictionary class]] && jsonResponse[@"records"]){
                [jsonResponse[@"records"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

                    CKRecordID* savedRecordID = [[CKRecordID alloc] initWithRecordName:obj[@"recordName"] zoneID:zoneID];
                    CKRecord* originalRecord = savedRecordIDToRecord[savedRecordID];

                    if(originalRecord){
                        NSError* recordError = nil;
                        if(obj[@"serverErrorCode"]){
                            recordError = [[NSError alloc] initWithCKErrorDictionary:obj];
                            [partialFailures setObject:recordError forKey:originalRecord.recordID];
                        }else{
                            [originalRecord updateWithDictionary:obj];
                            [savedRecords addObject:originalRecord];

                            if(self.perRecordProgressBlock){
                                self.perRecordProgressBlock(originalRecord, 1.0);
                            }
                        }

                        if(self.perRecordCompletionBlock){
                            self.perRecordCompletionBlock(originalRecord, recordError);
                        }
                    }else if(obj[@"deleted"]){
                        // was it deleted?
                        [deletedRecords addObject:savedRecordID];
                    }
                }];
            }else if(!error){
                error = [[NSError alloc] initWithCKErrorDictionary:jsonResponse];
            }



            if(!error && [[partialFailures allKeys] count]){
                NSDictionary* userInfo = @{ @"ContainerID" : self.database.container.containerIdentifier,
                                            @"CKPartialErrors" : partialFailures };
                error = [[NSError alloc] initWithDomain:CKErrorDomain code:CKErrorPartialFailure userInfo:userInfo];
            }
            
            if(self.modifyRecordsCompletionBlock){
                self.modifyRecordsCompletionBlock(savedRecords, deletedRecords, error);
            }

			[self setExecuting:NO];
			[self setFinished:YES];
        }];
    }
}

@end
