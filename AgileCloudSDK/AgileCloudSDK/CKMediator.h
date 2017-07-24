//
//  CKMediator.h
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "CKMediatorDelegate.h"

extern NSString *const kAgileCloudSDKInitializedNotification;

@interface CKMediator : NSObject

+ (CKMediator *)sharedMediator;

- (instancetype)init NS_UNAVAILABLE;

@property(nonatomic, weak) NSObject<CKMediatorDelegate> *delegate;
@property(nonatomic, readonly) BOOL isInitialized;

- (void)logout;
- (void)login;

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent;
- (void)handleGetURLString:(NSString *)urlString; // for handling URL from where the NSAppleEventDescriptor available - kevin 2017-07-24

@end
