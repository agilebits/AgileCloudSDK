//
//  CKFetchRecordZonesOperation.m
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits Inc. All rights reserved.
//

#import <AgileCloudKit/AgileCloudKit.h>
#import "CKDatabaseOperation_Private.h"
#import "CKDatabase_Private.h"
#import "Defines.h"

@implementation CKFetchRecordZonesOperation

- (instancetype)init
{
    if (self = [super init]) {
        _recordZoneIDs = nil;
    }
    return self;
}

- (instancetype)initWithRecordZoneIDs:(NSArray *)zoneIDs
{
    if (self = [self init]) {
        _recordZoneIDs = zoneIDs;
    }
    return self;
}

+ fetchAllRecordZonesOperation
{
    return [[CKFetchRecordZonesOperation alloc] init];
}


- (void)start
{
    if ([self isCancelled]) {
        [self setFinished:YES];
        return;
    }

    [self setExecuting:YES];

    if (!self.recordZoneIDs) {
		[[self database] fetchAllRecordZonesFromSender:self withCompletionHandler:^(NSArray *zones, NSError *error) {
            [self setExecuting:NO];
            [self setFinished:YES];
            
            if(!error){
                NSMutableDictionary* results = [NSMutableDictionary dictionary];
                
                for (CKRecordZone* zone in zones) {
                    if(!self.recordZoneIDs || [self.recordZoneIDs containsObject:zone.zoneID]){
                        results[zone.zoneID] = zone;
                    }
                }
                
                self.fetchRecordZonesCompletionBlock(results, nil);
            }else{
                self.fetchRecordZonesCompletionBlock(nil, error);
            }
        }];
    } else {
        // track our pending fetch count. this doesn't need to be
        // thread safe since cloudkitJS is single threaded
        __block NSInteger requestCount = [self.recordZoneIDs count];

        // our output
        NSMutableDictionary *fetchedZones = [NSMutableDictionary dictionary];
        NSMutableDictionary *errors = [NSMutableDictionary dictionary];

        // call this when we're done
        void (^completionBlock)() = ^{
            [self setExecuting:NO];
            [self setFinished:YES];
            
            NSError* err;
            if([errors count]){
                NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
                userInfo[CKPartialErrorsByItemIDKey] = errors;
                err = [[NSError alloc] initWithDomain:CKErrorDomain code:CKErrorPartialFailure userInfo:userInfo];
            }
            
            self.fetchRecordZonesCompletionBlock(fetchedZones, err);
        };

        // now save and delete everything
        for (CKRecordZoneID *zoneID in self.recordZoneIDs) {
			[[self database] fetchRecordZoneWithID:zoneID fromSender:self completionHandler:^(CKRecordZone *zone, NSError *error) {
                if(error){
                    errors[zoneID] = error;
                }else{
                    fetchedZones[zoneID] = zone;
                }
                requestCount -= 1;
                if(!requestCount){
                    completionBlock();
                }
            }];
        }
    }
}


@end
