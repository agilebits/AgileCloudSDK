//
//  CKReference+AgileDictionary.m
//  AgileCloudKit
//
//  Created by Adam Wulf on 9/14/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import "CKReference+AgileDictionary.h"

@implementation CKReference (AgileDictionary)

- (NSDictionary *)asAgileDictionary
{
    return @{ @"recordName": self.recordID.recordName,
              @"action": @((self.referenceAction == CKReferenceActionNone) ? 0 : 1) };
}

@end
