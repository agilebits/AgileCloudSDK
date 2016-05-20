//
//  CKFilter_Private.h
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import "CKFilter.h"

@interface CKFilter (Private)

- (instancetype)initWithDictionary:(NSDictionary *)dictionary inZone:(CKRecordZoneID *)zoneID;

- (NSDictionary *)asAgileDictionary;

@end
