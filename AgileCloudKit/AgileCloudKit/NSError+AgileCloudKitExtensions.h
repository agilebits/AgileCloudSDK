//
//  NSError+AgileCloudKitExtensions.h
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (AgileCloudKitExtensions)

- (instancetype)initWithCKErrorDictionary:(NSDictionary *)ckErrorDictionary;

@end
