//
//  CKFetchRecordZonesOperation.h
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits Inc. All rights reserved.
//

#import <AgileCloudKit/CKDatabaseOperation.h>

@interface CKFetchRecordZonesOperation : CKDatabaseOperation

+ (instancetype)fetchAllRecordZonesOperation;

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithRecordZoneIDs:(NSArray /* CKRecordZoneID */ *)zoneIDs;

@property(nonatomic, copy) NSArray /* CKRecordZoneID */ *recordZoneIDs;

/*  This block is called when the operation completes.
    The [NSOperation completionBlock] will also be called if both are set.
    If the error is CKErrorPartialFailure, the error's userInfo dictionary contains
    a dictionary of zoneIDs to errors keyed off of CKPartialErrorsByItemIDKey.
*/
@property(nonatomic, copy) void (^fetchRecordZonesCompletionBlock)(NSDictionary /* CKRecordZoneID -> CKRecordZone */ *recordZonesByZoneID, NSError *operationError);

@end
