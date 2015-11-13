//
//  CKFilter_Private.h
//  AgileCloudKit
//
//  Created by Adam Wulf on 9/14/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import <AgileCloudKit/AgileCloudKit.h>

@interface CKFilter (Private)

- (instancetype)initWithDictionary:(NSDictionary *)dictionary inZone:(CKRecordZoneID *)zoneID;

- (NSDictionary *)asAgileDictionary;

@end
