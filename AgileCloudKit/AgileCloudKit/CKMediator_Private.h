//
//  CKMediator_Private.h
//  AgileCloudKit
//
//  Created by Adam Wulf on 8/26/15.
//  Copyright © 2015 AgileBits. All rights reserved.
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
