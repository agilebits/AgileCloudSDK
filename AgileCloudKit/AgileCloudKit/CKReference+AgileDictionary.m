//
//  CKReference+AgileDictionary.m
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import "CKReference+AgileDictionary.h"

@implementation CKReference (AgileDictionary)

- (NSDictionary *)asAgileDictionary
{
    return @{ @"recordName": self.recordID.recordName,
              @"action": @((self.referenceAction == CKReferenceActionNone) ? 0 : 1) };
}

@end
