//
//  CKModifyRecordZonesOperation.h
//  CloudKit
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <AgileCloudKit/AgileCloudKit.h>
#import "CKDatabaseOperation_Private.h"
#import "NSArray+AgileMap.h"
#import "CKRecord+AgileDictionary.h"
#import "CKRecordID+AgileDictionary.h"
#import "CKRecordZoneID+AgileDictionary.h"
#import "CKRecord_Private.h"
#import "CKDatabase_Private.h"
#import "Defines.h"

@implementation CKModifyRecordZonesOperation

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}


- (instancetype)initWithRecordZonesToSave:(NSArray *)recordZonesToSave recordZoneIDsToDelete:(NSArray *)recordZoneIDsToDelete
{
    if (self = [self init]) {
        _recordZonesToSave = recordZonesToSave;
        _recordZoneIDsToDelete = recordZoneIDsToDelete;
    }
    return self;
}

- (void)start
{
    [self setExecuting:YES];

    if ([_recordZoneIDsToDelete count] || [_recordZonesToSave count]) {
        NSMutableDictionary *savedZoneIDToZone = [NSMutableDictionary dictionary];

        NSArray *ops = @[];
        ops = [ops arrayByAddingObjectsFromArray:[_recordZoneIDsToDelete agile_mapUsingBlock:^id(id obj, NSUInteger idx) {
            return @{ @"operationType" : @"delete",
                      @"zone" : @{ @"zoneID": [obj asAgileDictionary] } };
        }]];


        ops = [ops arrayByAddingObjectsFromArray:[_recordZonesToSave agile_mapUsingBlock:^id(id obj, NSUInteger idx) {
            [savedZoneIDToZone setObject:obj forKey:[obj zoneID]];
            return @{ @"operationType" : @"create",
                      @"zone" : [obj asAgileDictionary] };
        }]];

        NSDictionary *requestDictionary = @{ @"operations": ops };

        [self.database sendPOSTRequestTo:@"zones/modify" withJSON:requestDictionary completionHandler:^(id jsonResponse, NSError *error) {
            NSMutableArray* savedZones = [NSMutableArray array];
            NSMutableArray* deletedZones = [NSMutableArray array];
            NSMutableDictionary* partialFailures = [NSMutableDictionary dictionary];

            if([jsonResponse isKindOfClass:[NSDictionary class]] && jsonResponse[@"zones"]){
                [jsonResponse[@"zones"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

                    CKRecordZoneID* savedZoneID = [[CKRecordZoneID alloc] initWithZoneName:obj[@"zoneID"][@"zoneName"]];
                    CKRecordZone* originalZone = savedZoneIDToZone[savedZoneID];

                    if(originalZone){
                        NSError* recordError = nil;
                        if(obj[@"serverErrorCode"]){
                            recordError = [[NSError alloc] initWithCKErrorDictionary:obj];
                            [partialFailures setObject:recordError forKey:originalZone.zoneID];
                        }else{
                            [savedZones addObject:originalZone];
                        }
                    }else if(obj[@"deleted"]){
                        // was it deleted?
                        [deletedZones addObject:savedZoneID];
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
            
            if(self.modifyRecordZonesCompletionBlock){
                self.modifyRecordZonesCompletionBlock(savedZones, deletedZones, error);
            }
        }];

        [self setExecuting:NO];
        [self setFinished:YES];
    }
}

@end
