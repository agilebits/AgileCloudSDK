//
//  NSApplication+AgileCloudSDK.m
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import "NSApplication+AgileCloudSDK.h"
#import "CKMediator.h"
#import "CKMediator_Private.h"
#import <objc/runtime.h>
#import "Defines.h"

@implementation NSApplication (AgileCloudSDK)

- (void)_agilecloudsdk_swizzle_registerForRemoteNotificationTypes:(NSRemoteNotificationType)types
{
    [[CKMediator sharedMediator] registerForRemoteNotifications];
}

- (void)_agilecloudsdk_swizzle_unregisterForRemoteNotifications
{
    DebugLog(CKLOG_LEVEL_DEBUG, @"unregisterForRemoteNotifications");
}


- (NSRemoteNotificationType)_agilecloudsdk_swizzle_enabledRemoteNotificationTypes
{
    return NSRemoteNotificationTypeNone;
}


+ (void)load
{
    // registerForRemoteNotificationTypes:
    SEL originalSelector = @selector(registerForRemoteNotificationTypes:);
    SEL newSelector = @selector(_agilecloudsdk_swizzle_registerForRemoteNotificationTypes:);
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method newMethod = class_getInstanceMethod(self, newSelector);

    method_exchangeImplementations(originalMethod, newMethod);

    // unregisterForRemoteNotifications
    originalSelector = @selector(unregisterForRemoteNotifications);
    newSelector = @selector(_agilecloudsdk_swizzle_unregisterForRemoteNotifications);
    originalMethod = class_getInstanceMethod(self, originalSelector);
    newMethod = class_getInstanceMethod(self, newSelector);

    method_exchangeImplementations(originalMethod, newMethod);

    // enabledRemoteNotificationTypes
    originalSelector = @selector(enabledRemoteNotificationTypes);
    newSelector = @selector(_agilecloudsdk_swizzle_enabledRemoteNotificationTypes);
    originalMethod = class_getInstanceMethod(self, originalSelector);
    newMethod = class_getInstanceMethod(self, newSelector);

    method_exchangeImplementations(originalMethod, newMethod);
}

@end
