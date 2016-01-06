//
//  CKDatabase_Private.h
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import <AgileCloudKit/AgileCloudKit.h>

@interface CKDatabase (Private)

@property(nonatomic, readonly) CKContainer *container;

- (void)fetchAllRecordZonesOnInnerQueue:(BOOL)onInnerQueue withCompletionHandler:(void (^)(NSArray /* CKRecordZone */ *zones, NSError *error))completionHandler;
- (void)fetchRecordZoneWithID:(CKRecordZoneID *)zoneID onInnerQueue:(BOOL)onInnerQueue completionHandler:(void (^)(CKRecordZone *zone, NSError *error))completionHandler;

- (void)sendPOSTRequestTo:(NSString *)fragment withJSON:(id)postData completionHandler:(void (^)(id jsonResponse, NSError *error))completionHandler;

@end
