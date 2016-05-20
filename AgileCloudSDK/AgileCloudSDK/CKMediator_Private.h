//
//  CKMediator_Private.h
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import "CKMediator.h"

extern NSString *const CloudContainerNameKey;
extern NSString *const CloudAPITokenKey;
extern NSString *const CloudEnvironmentKey;

extern NSString *const CKAccountStatusNotificationUserInfoKey;

@interface CKMediator ()

@property(nonatomic, readonly) NSOperationQueue *queue;
@property(nonatomic, readonly) NSOperationQueue *innerQueue;
@property(nonatomic, readonly) WebView *cloudWebView;
@property(nonatomic, readonly) NSString *sessionToken;
@property(nonatomic, readonly) NSArray *containerProperties;

- (JSContext *)context;

- (NSDictionary *)infoForContainerID:(NSString *)containerID;

- (void)registerForRemoteNotifications;

- (void)addOperation:(NSOperation *)operation;
- (void)addInnerOperation:(NSOperation *)operation;

@end
