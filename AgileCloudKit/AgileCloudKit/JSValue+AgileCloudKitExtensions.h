//
//  JSValue+AgileCloudKitExtensions.h
//  AgileCloudKit
//
//  Created by Adam Wulf on 8/27/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

@interface JSValue (AgileCloudKitExtensions)

- (JSValue *)agile_invokeMethod:(NSString *)method;

@end
