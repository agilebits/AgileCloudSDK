//
//  CKQueryOperation.m
//  AgileCloudSDK
//
//  Created by Adam Wulf on 6/22/16.
//  Copyright © 2016 AgileBits. All rights reserved.
//

#import "CKQueryOperation.h"
#import "CKDatabaseOperation_Private.h"
#import "CKQuery+AgileDictionary.h"
#import "CKRecordZoneID+AgileDictionary.h"
#import "CKRecord_Private.h"
#import "CKDatabase_Private.h"

const NSUInteger CKQueryOperationMaximumResults = 200;

@implementation CKQueryOperation

- (instancetype)init{
    if(self = [super init]){
        
    }
    return self;
}
- (instancetype)initWithQuery:(CKQuery *)query{
    if(self = [super init]){
        _query = query;
    }
    return self;
}

- (void)start {
    [self setExecuting:YES];
    
    NSDictionary *requestDictionary = @{
                                        @"query": [self.query asAgileDictionary],
                                        @"zoneID": [self.zoneID asAgileDictionary],
                                        @"resultsLimit": @(200)
                                        };
    
    [self.database sendPOSTRequestTo:@"records/query" withJSON:requestDictionary completionHandler:^(id jsonResponse, NSError *error) {
        NSMutableArray* fetchedRecords = [NSMutableArray array];
        if ([jsonResponse isKindOfClass:[NSDictionary class]] && jsonResponse[@"records"]) {
            [jsonResponse[@"records"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSError* recordError = nil;
                CKRecord* record;
                CKRecordID* recordID;
                if (obj[@"serverErrorCode"]) {
                    recordError = [[NSError alloc] initWithCKErrorDictionary:obj];
                    if (obj[@"recordName"]) {
                        recordID = [[CKRecordID alloc] initWithRecordName:obj[@"recordName"]  zoneID:self.zoneID];
                    }
                }
                else {
                    record = [[CKRecord alloc] initWithDictionary:obj inZone:self.zoneID];
                    recordID = record.recordID;
                }
                if (record) {
                    NSArray* errs = [record synchronouslyDownloadAllAssetsWithProgressBlock:nil];
                    if ([errs count]) {
                        recordError = errs[0];
                    }
                    else {
                        [fetchedRecords addObject:record];
                    }
                }
                
                if (self.recordFetchedBlock && record) {
                    self.recordFetchedBlock(record);
                }
            }];
        }
        else if (!error) {
            error = [[NSError alloc] initWithCKErrorDictionary:jsonResponse];
        }
        
        if (self.queryCompletionBlock) {
            self.queryCompletionBlock(nil, error);
        }
        
        [self setExecuting:NO];
        [self setFinished:YES];
    }];
}

@end
