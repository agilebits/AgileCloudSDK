//
//  CKRecordZoneID+AgileDictionary.m
//  AgileCloudKit
//
//  Created by Adam Wulf on 9/8/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import "CKRecordZoneID+AgileDictionary.h"

@implementation CKRecordZoneID (AgileDictionary)

- (NSDictionary *)asAgileDictionary
{
    return @{ @"zoneName": self.zoneName,
              @"ownerName": self.ownerName };
}

@end
