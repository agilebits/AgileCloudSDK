//
//  CKMediator_Private.h
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import <AgileCloudKit/AgileCloudKit.h>

@interface CKMediator ()

@property(nonatomic, readonly) NSOperationQueue *queue;
@property(nonatomic, readonly) WebView *cloudKitWebView;
@property(nonatomic, readonly) NSString *sessionToken;
@property(nonatomic, readonly) NSArray *containerProperties;

- (JSContext *)context;

- (NSDictionary *)infoForContainerID:(NSString *)containerID;

- (void)registerForRemoteNotifications;

@end
