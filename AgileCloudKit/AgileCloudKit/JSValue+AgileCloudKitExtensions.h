//
//  JSValue+AgileCloudKitExtensions.h
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

@interface JSValue (AgileCloudKitExtensions)

- (JSValue *)agile_invokeMethod:(NSString *)method;

@end
