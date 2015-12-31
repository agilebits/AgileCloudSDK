//
//  CKFilter_Private.h
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import <AgileCloudKit/AgileCloudKit.h>

@interface CKFilter (Private)

- (instancetype)initWithDictionary:(NSDictionary *)dictionary inZone:(CKRecordZoneID *)zoneID;

- (NSDictionary *)asAgileDictionary;

@end
