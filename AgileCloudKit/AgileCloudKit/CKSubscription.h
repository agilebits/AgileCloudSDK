//
//  CKSubscription.h
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgileCloudKit/CKDefines.h>

typedef NS_ENUM(NSInteger, CKSubscriptionType) {
    CKSubscriptionTypeQuery = 1,
    CKSubscriptionTypeRecordZone = 2,
} NS_ENUM_AVAILABLE(10_10, 8_0);

typedef NS_OPTIONS(NSUInteger, CKSubscriptionOptions) {
    CKSubscriptionOptionsFiresOnRecordCreation = 1 << 0, // Applies to CKSubscriptionTypeQuery
    CKSubscriptionOptionsFiresOnRecordUpdate = 1 << 1, // Applies to CKSubscriptionTypeQuery
    CKSubscriptionOptionsFiresOnRecordDeletion = 1 << 2, // Applies to CKSubscriptionTypeQuery
    CKSubscriptionOptionsFiresOnce = 1 << 3, // Applies to CKSubscriptionTypeQuery
} NS_ENUM_AVAILABLE(10_10, 8_0);

@class CKNotificationInfo, CKRecordZoneID;

@interface CKSubscription : NSObject <NSSecureCoding, NSCopying>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithRecordType:(NSString *)recordType predicate:(NSPredicate *)predicate options:(CKSubscriptionOptions)subscriptionOptions /* NS_UNAVAILABLE */;

- (instancetype)initWithRecordType:(NSString *)recordType predicate:(NSPredicate *)predicate subscriptionID:(NSString *)subscriptionID options:(CKSubscriptionOptions)subscriptionOptions NS_DESIGNATED_INITIALIZER /* NS_UNAVAILABLE */;

- (instancetype)initWithRecordType:(NSString *)recordType filters:(NSArray *)filters options:(CKSubscriptionOptions)subscriptionOptions;

- (instancetype)initWithRecordType:(NSString *)recordType filters:(NSArray *)filters subscriptionID:(NSString *)subscriptionID options:(CKSubscriptionOptions)subscriptionOptions NS_DESIGNATED_INITIALIZER;

/* This subscription fires whenever any change happens in the indicated RecordZone.
 The RecordZone must have the capability CKRecordZoneCapabilityFetchChanges */
- (instancetype)initWithZoneID:(CKRecordZoneID *)zoneID options:(CKSubscriptionOptions)subscriptionOptions;
- (instancetype)initWithZoneID:(CKRecordZoneID *)zoneID subscriptionID:(NSString *)subscriptionID options:(CKSubscriptionOptions)subscriptionOptions NS_DESIGNATED_INITIALIZER;

@property(nonatomic, readonly, copy) NSString *subscriptionID;

@property(nonatomic, readonly, assign) CKSubscriptionType subscriptionType;

/* The record type that this subscription watches. This property is only used by query subscriptions, and must be set. */
@property(nonatomic, readonly, copy) NSString *recordType;

@property(nonatomic, readonly) NSArray *filters;

/* Options flags describing the firing behavior subscription. For query subscriptions, one of CKSubscriptionOptionsFiresOnRecordCreation, CKSubscriptionOptionsFiresOnRecordUpdate, or CKSubscriptionOptionsFiresOnRecordDeletion must be specified or an NSInvalidArgumentException will be thrown. */
@property(nonatomic, readonly, assign) CKSubscriptionOptions subscriptionOptions;

/* Optional property describing the notification that will be sent when the subscription fires. */
@property(nonatomic, copy) CKNotificationInfo *notificationInfo;

/* Query subscriptions: Optional property.  If set, a query subscription is scoped to only record changes in the indicated zone.
   RecordZone subscriptions: */
@property(nonatomic, copy) CKRecordZoneID *zoneID;

@end
