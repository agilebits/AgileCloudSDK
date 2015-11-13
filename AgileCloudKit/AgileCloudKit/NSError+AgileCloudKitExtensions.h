//
//  NSError+AgileCloudKitExtensions.h
//  AgileCloudKit
//
//  Created by Adam Wulf on 8/27/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (AgileCloudKitExtensions)

- (instancetype)initWithCKErrorDictionary:(NSDictionary *)ckErrorDictionary;

@end
