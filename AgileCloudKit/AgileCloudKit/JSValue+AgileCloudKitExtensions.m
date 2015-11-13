//
//  JSValue+AgileCloudKitExtensions.m
//  AgileCloudKit
//
//  Created by Adam Wulf on 8/27/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import "JSValue+AgileCloudKitExtensions.h"

@implementation JSValue (AgileCloudKitExtensions)

- (JSValue *)agile_invokeMethod:(NSString *)method
{
    return [self invokeMethod:method withArguments:@[]];
}

@end
