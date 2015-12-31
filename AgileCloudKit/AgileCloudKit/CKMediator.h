//
//  CKMediator.h
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <AgileCloudKit/CKMediatorDelegate.h>

extern NSString *const kAgileCloudKitInitializedNotification;

@interface CKMediator : NSObject

+ (CKMediator *)sharedMediator;

- (instancetype)init NS_UNAVAILABLE;

@property(nonatomic, weak) NSObject<CKMediatorDelegate> *delegate;
@property(nonatomic, readonly) BOOL isInitialized;

- (void)logout;
- (void)login;

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent;

@end
