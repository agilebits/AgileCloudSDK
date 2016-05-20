//
//  CKContainer_Private.h
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import "CKContainer.h"

@interface CKContainer ()

+ (NSOperationQueue *)urlQueue;
+ (NSURLSession *)downloadSession;
+ (NSURLSession *)uploadSession;

@property(nonatomic, readonly) NSString *cloudContainerName;
@property(nonatomic, readonly) NSString *cloudAPIToken;
@property(nonatomic, readonly) NSString *cloudEnvironment;

@property (nonatomic, copy) void (^accountStatusCompletionHandler)(CKAccountStatus, NSError *);

- (JSValue *)asJSValue;

#pragma mark - Push Notifications

- (void)registerForRemoteNotifications;

#pragma mark - Web Services

+ (void)sendPOSTRequestTo:(NSURL *)fetchURL withJSON:(id)postData completionHandler:(void (^)(id jsonResponse, NSError *error))completionHandler;
+ (void)sendPOSTRequestTo:(NSURL *)uploadDestination withFile:(NSURL *)localFile completionHandler:(void (^)(id jsonResponse, NSError *error))completionHandler;
+ (NSString *)percentEscape:(NSString *)str;

@end
