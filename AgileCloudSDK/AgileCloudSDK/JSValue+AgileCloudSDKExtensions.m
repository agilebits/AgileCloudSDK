//
//  JSValue+AgileCloudSDKExtensions.m
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import "JSValue+AgileCloudSDKExtensions.h"

@implementation JSValue (AgileCloudSDKExtensions)

- (JSValue *)agile_invokeMethod:(NSString *)method
{
    return [self invokeMethod:method withArguments:@[]];
}

@end
