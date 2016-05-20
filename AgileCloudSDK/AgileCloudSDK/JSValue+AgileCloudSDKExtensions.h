//
//  JSValue+AgileCloudSDKExtensions.h
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

@interface JSValue (AgileCloudSDKExtensions)

- (JSValue *)agile_invokeMethod:(NSString *)method;

@end
