//
//  CKRecordID+AgileDictionary.m
//  AgileCloudKit
//
//  Created by Adam Wulf on 9/8/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import "CKRecordID+AgileDictionary.h"

@implementation CKRecordID (AgileDictionary)

- (NSDictionary *)asAgileDictionary
{
    return @{ @"recordName": self.recordName,
              @"zoneID": self.zoneID.zoneName };
}

@end
