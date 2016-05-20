//
//  NSError+AgileCloudSDKExtensions.h
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (AgileCloudSDKExtensions)

- (instancetype)initWithCKErrorDictionary:(NSDictionary *)ckErrorDictionary;

@end
