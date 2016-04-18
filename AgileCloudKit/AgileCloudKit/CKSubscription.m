//
//  CKSubscription.m
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgileCloudKit/AgileCloudKit.h>
#import "CKSubscription.h"
#import "CKSubscription+AgileDictionary.h"
#import "CKRecordZoneID_Private.h"
#import "CKSubscription_Private.h"
#import "NSArray+AgileMap.h"
#import "CKFilter.h"
#import "CKFilter_Private.h"
#import "CKNotificationInfo_Private.h"
#import "Defines.h"

@implementation CKSubscription

- (instancetype)initWithRecordType:(NSString *)recordType filters:(NSArray *)filters options:(CKSubscriptionOptions)subscriptionOptions {
	return [self initWithRecordType:recordType filters:filters subscriptionID:[[NSUUID UUID] UUIDString] options:subscriptionOptions];
}

- (instancetype)initWithRecordType:(NSString *)recordType filters:(NSArray *)filters subscriptionID:(NSString *)subscriptionID options:(CKSubscriptionOptions)subscriptionOptions {
	if (self = [super init]) {
		_subscriptionID = subscriptionID;
		_subscriptionType = CKSubscriptionTypeQuery;
		_subscriptionOptions = subscriptionOptions;
		_recordType = recordType;
		_filters = [filters copy];
	}
	return self;
}


- (instancetype)initWithRecordType:(NSString *)recordType predicate:(NSPredicate *)predicate options:(CKSubscriptionOptions)subscriptionOptions {
	return [self initWithRecordType:recordType predicate:predicate subscriptionID:[[NSUUID UUID] UUIDString] options:subscriptionOptions];
}

- (instancetype)initWithRecordType:(NSString *)recordType predicate:(NSPredicate *)predicate subscriptionID:(NSString *)subscriptionID options:(CKSubscriptionOptions)subscriptionOptions {
	if (self = [super init]) {
		_subscriptionID = subscriptionID;
		_subscriptionType = CKSubscriptionTypeQuery;
		_subscriptionOptions = subscriptionOptions;
		_recordType = recordType;
		
		_filters = @[];
	}
	return self;
}

/* This subscription fires whenever any change happens in the indicated RecordZone.
 The RecordZone must have the capability CKRecordZoneCapabilityFetchChanges */
- (instancetype)initWithZoneID:(CKRecordZoneID *)zoneID options:(CKSubscriptionOptions)subscriptionOptions {
	return [self initWithZoneID:zoneID subscriptionID:[[NSUUID UUID] UUIDString] options:subscriptionOptions];
}

- (instancetype)initWithZoneID:(CKRecordZoneID *)zoneID subscriptionID:(NSString *)subscriptionID options:(CKSubscriptionOptions)subscriptionOptions {
	if (self = [super init]) {
		_zoneID = zoneID;
		_subscriptionID = subscriptionID;
		_subscriptionOptions = subscriptionOptions;
		_subscriptionType = CKSubscriptionTypeRecordZone;
	}
	return self;
}


- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]) {
		[self updateWithDictionary:dictionary];
	}
	return self;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary {
	_subscriptionType = [dictionary[@"subscriptionType"] isEqualToString:@"query"] ? CKSubscriptionTypeQuery : CKSubscriptionTypeRecordZone;
	_notificationInfo = [[CKNotificationInfo alloc] initWithDictionary:dictionary[@"notificationInfo"]];
	_subscriptionID = dictionary[@"subscriptionID"];
	_subscriptionOptions = [dictionary[@"firesOn"] containsObject:@"create"] ? CKSubscriptionOptionsFiresOnRecordCreation : 0;
	_subscriptionOptions |= [dictionary[@"firesOn"] containsObject:@"update"] ? CKSubscriptionOptionsFiresOnRecordUpdate : 0;
	_subscriptionOptions |= [dictionary[@"firesOn"] containsObject:@"delete"] ? CKSubscriptionOptionsFiresOnRecordDeletion : 0;
	if (_subscriptionType == CKSubscriptionTypeQuery) {
		_recordType = dictionary[@"query"][@"recordType"];
		_zoneID = [[CKRecordZoneID alloc] initWithDictionary:[dictionary objectForKey:@"zoneID"]];
		_filters = [dictionary[@"query"][@"filterBy"] agile_mapUsingBlock:^id(id obj, NSUInteger idx) {
			return [[CKFilter alloc] initWithDictionary:obj inZone:_zoneID];
		}];
	} else {
		_zoneID = [[CKRecordZoneID alloc] initWithDictionary:[dictionary objectForKey:@"zoneID"]];
	}
}

#pragma mark - NSCoding

+ (BOOL)supportsSecureCoding {
	return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:@(_subscriptionType) forKey:@"subscriptionType"];
	[aCoder encodeObject:_subscriptionID forKey:@"subscriptionID"];
	[aCoder encodeObject:@(_subscriptionOptions) forKey:@"subscriptionOptions"];
	if (self.subscriptionType == CKSubscriptionTypeQuery) {
		[aCoder encodeObject:_recordType forKey:@"recordType"];
		[aCoder encodeObject:_filters forKey:@"filters"];
	} else {
		[aCoder encodeObject:_zoneID forKey:@"zoneID"];
	}
	[aCoder encodeObject:_notificationInfo forKey:@"notificationInfo"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super init]) {
		_subscriptionType = [aDecoder decodeIntegerForKey:@"subscriptionType"];
		_notificationInfo = [aDecoder decodeObjectOfClass:[CKNotificationInfo class] forKey:@"notificationInfo"];
		_subscriptionID = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"subscriptionID"];
		_subscriptionOptions = [aDecoder decodeIntegerForKey:@"subscriptionOptions"];
		if (_subscriptionType == CKSubscriptionTypeQuery) {
			_recordType = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"recordType"];
			_filters = [aDecoder decodeObjectOfClass:[NSArray class] forKey:@"filters"];
		} else {
			_zoneID = [aDecoder decodeObjectOfClass:[CKRecordZoneID class] forKey:@"zoneID"];
		}
	}
	return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
	return [[[self class] allocWithZone:zone] initWithDictionary:[self asAgileDictionary]];
}

#pragma mark - Description

- (NSString *)description {
	return [NSString stringWithFormat:@"[CKSubscription: %@]", self.subscriptionID];
}


@end
