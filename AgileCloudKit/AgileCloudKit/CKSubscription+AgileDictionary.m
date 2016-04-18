//
//  CKSubscription+AgileDictionary.m
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import "CKSubscription.h"
#import "CKSubscription+AgileDictionary.h"
#import "CKRecordZoneID+AgileDictionary.h"
#import "CKSubscription_Private.h"
#import "NSArray+AgileMap.h"
#import "CKNotificationInfo+AgileDictionary.h"

@implementation CKSubscription (AgileDictionary)

- (NSDictionary *)asAgileDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:self.subscriptionID forKey:@"subscriptionID"];
    [dictionary setObject:self.subscriptionType == CKSubscriptionTypeQuery ? @"query" : @"zone" forKey:@"subscriptionType"];
    if (self.zoneID) {
        [dictionary setObject:[self.zoneID asAgileDictionary] forKey:@"zoneID"];
    }
    if (self.recordType) {
        [dictionary setObject:@{ @"recordType": self.recordType,
                                 @"filterBy": [self.filters agile_mapUsingSelector:@selector(asAgileDictionary)],
                                 @"sortBy": @[] }
                       forKey:@"query"];
    }
    if (self.subscriptionOptions) {
        NSMutableArray *opts = [NSMutableArray array];
        if (self.subscriptionOptions & CKSubscriptionOptionsFiresOnRecordCreation) {
            [opts addObject:@"create"];
        }
        if (self.subscriptionOptions & CKSubscriptionOptionsFiresOnRecordUpdate) {
            [opts addObject:@"update"];
        }
        if (self.subscriptionOptions & CKSubscriptionOptionsFiresOnRecordDeletion) {
            [opts addObject:@"delete"];
        }
        [dictionary setObject:opts forKey:@"firesOn"];
    }
    if (self.subscriptionOptions & CKSubscriptionOptionsFiresOnce) {
        [dictionary setObject:@(YES) forKey:@"firesOnce"];
    } else {
        [dictionary setObject:@(NO) forKey:@"firesOnce"];
    }
    if (self.notificationInfo) {
        [dictionary setObject:[self.notificationInfo asAgileDictionary]
                       forKey:@"notificationInfo"];
    } else {
        [dictionary setObject:@{}
                       forKey:@"notificationInfo"];
    }
    if (self.subscriptionType == CKSubscriptionTypeRecordZone) {
        [dictionary setObject:@(YES) forKey:@"zoneWide"];
    }
    return dictionary;
}

@end
