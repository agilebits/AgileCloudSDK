//
//  CKAsset+AgileDictionary.m
//  AgileCloudKit
//
//  Created by Adam Wulf on 9/12/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import "CKAsset+AgileDictionary.h"
#import "CKAsset_Private.h"

@implementation CKAsset (AgileDictionary)

- (NSDictionary *)asAgileDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{ @"fileChecksum": self.fileChecksum,
                                                                                 @"referenceChecksum": self.referenceChecksum,
                                                                                 @"size": @(self.fileSize),
                                                                                 @"wrappingKey": self.wrappingKey }];
    if (self.receipt) {
        [dict setObject:self.receipt forKey:@"receipt"];
    }
    return dict;
}

@end
