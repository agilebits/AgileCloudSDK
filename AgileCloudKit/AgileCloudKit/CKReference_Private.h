//
//  CKReference_Private.h
//  AgileCloudKit
//
//  Created by Adam Wulf on 9/9/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKRecord.h"

@interface CKReference (Private)

- (instancetype)initWithDictionary:(NSDictionary *)dictionary inZone:(CKRecordZoneID *)zoneID;

- (void)updateWithDictionary:(NSDictionary *)dictionary;

@end
