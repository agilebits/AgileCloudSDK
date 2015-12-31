//
//  JSValue+AgileCloudKitExtensions.m
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import "JSValue+AgileCloudKitExtensions.h"

@implementation JSValue (AgileCloudKitExtensions)

- (JSValue *)agile_invokeMethod:(NSString *)method
{
    return [self invokeMethod:method withArguments:@[]];
}

@end
