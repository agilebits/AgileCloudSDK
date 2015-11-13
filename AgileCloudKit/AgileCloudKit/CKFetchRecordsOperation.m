//
//  CKFetchRecordsOperation.h
//  CloudKit
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <AgileCloudKit/AgileCloudKit.h>
#import "CKDatabaseOperation_Private.h"
#import "NSError+AgileCloudKitExtensions.h"
#import "NSArray+AgileMap.h"
#import "CKRecordID+AgileDictionary.h"
#import "CKDatabase_Private.h"
#import "CKRecord_Private.h"
#import "Defines.h"

@implementation CKFetchRecordsOperation

+ (instancetype)fetchCurrentUserRecordOperation
{
    @throw kAbstractMethodException;
}

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (instancetype)initWithRecordIDs:(NSArray *)recordIDs
{
    if (self = [self init]) {
        _recordIDs = [recordIDs copy];
    }
    return self;
}

- (void)start
{
    [self setExecuting:YES];

    if ([_recordIDs count]) {
        CKRecordZoneID *zone = [[_recordIDs firstObject] zoneID];

        NSArray *jsonRecordIds = [_recordIDs agile_mapUsingBlock:^id(id obj, NSUInteger idx) {
            return [obj asAgileDictionary];
        }];

        NSDictionary *requestDictionary = @{
            @"records": jsonRecordIds,
            @"zoneID": @{
                @"zoneName": zone.zoneName
            }
        };

        [self.database sendPOSTRequestTo:@"records/lookup" withJSON:requestDictionary completionHandler:^(id jsonResponse, NSError *error) {
            NSMutableDictionary* fetchedRecords = [NSMutableDictionary dictionary];
            NSMutableDictionary* partialFailures = [NSMutableDictionary dictionary];
            if([jsonResponse isKindOfClass:[NSDictionary class]] && jsonResponse[@"records"]){
                [jsonResponse[@"records"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSError* recordErr = nil;
                    CKRecord* record;
                    CKRecordID* recordID;
                    if(obj[@"serverErrorCode"]){
                        recordErr = [[NSError alloc] initWithCKErrorDictionary:obj];
                        if(obj[@"recordName"]){
                            recordID = [[CKRecordID alloc] initWithRecordName:obj[@"recordName"]  zoneID:zone];
                        }
                    }else{
                        record = [[CKRecord alloc] initWithDictionary:obj inZone:zone];
                        recordID = record.recordID;
                    }
                    if(record){
                        NSArray* errs = [record synchronouslyDownloadAllAssetsWithProgressBlock:^(double progress) {
                            if(self.perRecordProgressBlock && progress != 1.0){
                                self.perRecordProgressBlock(recordID, progress);
                            }
                        }];
                        if([errs count]){
                            recordErr = errs[0];
                        }else{
                            [fetchedRecords setObject:record forKey:recordID];
                            if(self.perRecordProgressBlock){
                                self.perRecordProgressBlock(recordID, 1.0);
                            }
                        }
                    }

                    if(self.perRecordCompletionBlock){
                        self.perRecordCompletionBlock(record, recordID, recordErr);
                    }
                    
                    if(recordErr){
                        [partialFailures setObject:recordErr forKey:recordID];
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

            if(self.fetchRecordsCompletionBlock){
                self.fetchRecordsCompletionBlock(fetchedRecords, error);
            }

            [self setExecuting:NO];
            [self setFinished:YES];
        }];
    } else {
        [self setExecuting:NO];
        [self setFinished:YES];
    }
}

@end
