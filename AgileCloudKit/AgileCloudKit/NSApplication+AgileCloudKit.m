//
//  NSApplication+AgileCloudKit.m
//  AgileCloudKit
//
//  Created by Adam Wulf on 9/20/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import "NSApplication+AgileCloudKit.h"
#import "CKMediator.h"
#import "CKMediator_Private.h"
#import <objc/runtime.h>
#import "Defines.h"

@implementation NSApplication (AgileCloudKit)

- (void)_agilecloudkit_swizzle_registerForRemoteNotificationTypes:(NSRemoteNotificationType)types
{
    [[CKMediator sharedMediator] registerForRemoteNotifications];
}

- (void)_agilecloudkit_swizzle_unregisterForRemoteNotifications
{
    DebugLog(@"unregisterForRemoteNotifications");
}


- (NSRemoteNotificationType)_agilecloudkit_swizzle_enabledRemoteNotificationTypes
{
    return NSRemoteNotificationTypeNone;
}


+ (void)load
{
    // registerForRemoteNotificationTypes:
    SEL originalSelector = @selector(registerForRemoteNotificationTypes:);
    SEL newSelector = @selector(_agilecloudkit_swizzle_registerForRemoteNotificationTypes:);
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method newMethod = class_getInstanceMethod(self, newSelector);

    method_exchangeImplementations(originalMethod, newMethod);

    // unregisterForRemoteNotifications
    originalSelector = @selector(unregisterForRemoteNotifications);
    newSelector = @selector(_agilecloudkit_swizzle_unregisterForRemoteNotifications);
    originalMethod = class_getInstanceMethod(self, originalSelector);
    newMethod = class_getInstanceMethod(self, newSelector);

    method_exchangeImplementations(originalMethod, newMethod);

    // enabledRemoteNotificationTypes
    originalSelector = @selector(enabledRemoteNotificationTypes);
    newSelector = @selector(_agilecloudkit_swizzle_enabledRemoteNotificationTypes);
    originalMethod = class_getInstanceMethod(self, originalSelector);
    newMethod = class_getInstanceMethod(self, newSelector);

    method_exchangeImplementations(originalMethod, newMethod);
}

@end
