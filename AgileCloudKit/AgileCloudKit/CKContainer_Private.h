//
//  CKContainer_Private.h
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//


@interface CKContainer ()

+ (NSOperationQueue *)urlQueue;
+ (NSURLSession *)downloadSession;
+ (NSURLSession *)uploadSession;

@property(nonatomic, readonly) NSString *cloudKitContainerName;
@property(nonatomic, readonly) NSString *cloudKitAPIToken;
@property(nonatomic, readonly) NSString *cloudKitEnvironment;

@property (nonatomic, copy) void (^accountStatusCompletionHandler)(CKAccountStatus, NSError *);

- (JSValue *)asJSValue;

#pragma mark - Push Notifications

- (void)registerForRemoteNotifications;

#pragma mark - Web Services

+ (void)sendPOSTRequestTo:(NSURL *)fetchURL withJSON:(id)postData completionHandler:(void (^)(id jsonResponse, NSError *error))completionHandler;
+ (void)sendPOSTRequestTo:(NSURL *)uploadDestination withFile:(NSURL *)localFile completionHandler:(void (^)(id jsonResponse, NSError *error))completionHandler;
+ (NSString *)percentEscape:(NSString *)str;

@end
