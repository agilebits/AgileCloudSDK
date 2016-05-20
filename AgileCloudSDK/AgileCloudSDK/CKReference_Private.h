//
//  CKReference_Private.h
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKRecord.h"

@interface CKReference (Private)

- (instancetype)initWithDictionary:(NSDictionary *)dictionary inZone:(CKRecordZoneID *)zoneID;

- (void)updateWithDictionary:(NSDictionary *)dictionary;

@end
