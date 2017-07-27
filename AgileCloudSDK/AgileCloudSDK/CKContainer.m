//
//  CKContainer.m
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <WebKit/WebKit.h>
#import <WebKit/WebFrameLoadDelegate.h>
#import "CKMediator_Private.h"
#import "CKBlockOperation.h"
#import "Defines.h"
#import "CKContainer_Private.h"
#import "CKDatabase.h"
#import "JSValue+AgileCloudSDKExtensions.h"
#import "NSError+AgileCloudSDKExtensions.h"
#import "CKError.h"
#import "CKOperation.h"

// This constant represents the current user's ID for zone ID
NSString *const CKOwnerDefaultName = @"__defaultOwner__";

@interface CKContainer (Private)

- (instancetype)init NS_AVAILABLE(10_10, 8_0);

@end

@implementation CKContainer {
	CKDatabase *_publicCloudDatabase;
	CKDatabase *_privateCloudDatabase;
	NSDictionary *_containerProperties;
}

@synthesize containerIdentifier;

static CGFloat targetInterval;
static NSOperationQueue *_urlQueue;
+ (NSOperationQueue *)urlQueue {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_urlQueue = [[NSOperationQueue alloc] init];
		_urlQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
	});
	return _urlQueue;
}

static NSURLSession *_downloadSession;
+ (NSURLSession *)downloadSession {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_downloadSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:_urlQueue];
	});
	return _downloadSession;
}

static NSURLSession *_uploadSession;
+ (NSURLSession *)uploadSession {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_uploadSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:_urlQueue];
	});
	return _uploadSession;
}

static CKContainer *_defaultContainer;

+ (CKContainer *)defaultContainer {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_defaultContainer = [CKContainer containerWithIdentifier:[[[CKMediator sharedMediator] containerProperties] firstObject][CloudContainerNameKey]];
	});
	return _defaultContainer;
}

static NSMutableDictionary *containers;

+ (CKContainer *)containerWithIdentifier:(NSString *)containerIdentifier {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		containers = [NSMutableDictionary dictionary];
	});
	if (![containers objectForKey:containerIdentifier]) {
		NSDictionary *properties = [[CKMediator sharedMediator] infoForContainerID:containerIdentifier];
		CKContainer *container = [[CKContainer alloc] initWithProperties:properties];
		[containers setObject:container forKey:containerIdentifier];
	}
	return [containers objectForKey:containerIdentifier];
}

#pragma mark - Initializer and Private Properties

- (instancetype)initWithProperties:(NSDictionary *)properties {
	if (self = [super init]) {
		if (!properties) {
			@throw [NSException exceptionWithName:@"CKContainerException" reason:@"No properties found for container" userInfo:nil];
		}
		_containerProperties = properties;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudIdentityDidChange:) name:NSUbiquityIdentityDidChangeNotification object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)containerIdentifier {
	return _containerProperties[CloudContainerNameKey];
}

// each container contains keys for: CloudContainerName, CloudAPIToken, CloudEnvironment
- (NSString *)cloudContainerName {
	return [[CKMediator sharedMediator] infoForContainerID:self.containerIdentifier][CloudContainerNameKey];
}

- (NSString *)cloudAPIToken {
	return [[CKMediator sharedMediator] infoForContainerID:self.containerIdentifier][CloudAPITokenKey];
}

- (NSString *)cloudEnvironment {
	return [[CKMediator sharedMediator] infoForContainerID:self.containerIdentifier][CloudEnvironmentKey];
}

- (JSValue *)asJSValue {
	if (![[CKMediator sharedMediator] isInitialized]) {
		@throw [NSException exceptionWithName:@"CannotUseContainerUntilInitialized" reason:@"Before using this container, CKMediator must be initialized" userInfo:nil];
	}
	__block JSValue *value;
	void (^block)(void) = ^{
		value = [[[[CKMediator sharedMediator] context] evaluateScript:@"CloudKit"] invokeMethod:@"getContainer" withArguments:@[self.containerIdentifier]];
	};
	if (![NSThread isMainThread]) {
		dispatch_sync(dispatch_get_main_queue(), block);
	}
	else {
		block();
	}
	return value;
}

#pragma mark - Properties

- (CKDatabase *)publicCloudDatabase {
	if (!_publicCloudDatabase) {
		_publicCloudDatabase = [[[CKDatabase class] alloc] initWithContainer:self isPublic:YES];
	}
	
	return _publicCloudDatabase;
}

- (CKDatabase *)privateCloudDatabase {
	if (!_privateCloudDatabase) {
		_privateCloudDatabase = [[[CKDatabase class] alloc] initWithContainer:self isPublic:NO];
	}
	
	return _privateCloudDatabase;
}

#pragma mark - Methods

- (void)addOperation:(CKOperation *)operation {
	[[[CKMediator sharedMediator] queue] addOperation:operation];
}

- (void)accountStatusWithCompletionHandler:(void (^)(CKAccountStatus, NSError *))completionHandler {
	CKBlockOperation *blockOp = [[CKBlockOperation alloc] initWithBlock:^(void (^opCompletionBlock)(void)) {
		[[[[self asJSValue] agile_invokeMethod:@"fetchUserInfo"] invokeMethod:@"then" withArguments:@[^(id userinfo) {
			completionHandler(userinfo ? CKAccountStatusAvailable : CKAccountStatusNoAccount, nil);
			opCompletionBlock();
		}]] invokeMethod:@"catch"
		 withArguments:@[^(id errorDictionary) {
			NSError* error = [[NSError alloc] initWithCKErrorDictionary:errorDictionary];
			if (error.code == CKErrorNotAuthenticated) {
				self.accountStatusCompletionHandler = completionHandler;
				[[CKMediator sharedMediator] login];
			}
			else {
				completionHandler(CKAccountStatusCouldNotDetermine, error);
			}
			opCompletionBlock();
		}]];
	}];
	[[[CKMediator sharedMediator] queue] addOperation:blockOp];
}

- (void)statusForApplicationPermission:(CKApplicationPermissions)applicationPermission completionHandler:(CKApplicationPermissionBlock)completionHandler {
	CKBlockOperation *blockOp = [[CKBlockOperation alloc] initWithBlock:^(void (^opCompletionBlock)(void)) {
		[[[[self asJSValue] agile_invokeMethod:@"fetchUserInfo"] invokeMethod:@"then" withArguments:@[^(id userinfo) {
			if ([[userinfo objectForKey:@"isDiscoverable"] boolValue]) {
				completionHandler(CKApplicationPermissionStatusGranted, nil);
			}
			else {
				completionHandler(CKApplicationPermissionStatusInitialState, nil);
			}
			opCompletionBlock();
		}]] invokeMethod:@"catch"
		 withArguments:@[^(id errorDictionary) {
			NSError* error = [[NSError alloc] initWithCKErrorDictionary:errorDictionary];
			completionHandler(CKApplicationPermissionStatusCouldNotComplete, error);
			opCompletionBlock();
		}]];
	}];
	[[[CKMediator sharedMediator] queue] addOperation:blockOp];
}

#pragma mark - Push Notifications

- (void)registerForRemoteNotifications {
	CKBlockOperation *blockOp = [[CKBlockOperation alloc] initWithBlock:^(void (^opCompletionBlock)(void)) {
		NSString *createRemoteNotificationTokenURL = [NSString stringWithFormat:@"https://api.apple-cloudkit.com/device/1/%@/%@/tokens/create?ckAPIToken=%@&ckSession=%@",
													  self.cloudContainerName,
													  self.cloudEnvironment,
													  self.cloudAPIToken,
													  [CKContainer percentEscape:[CKMediator sharedMediator].sessionToken]];
		
		NSDictionary *postData = @{ @"apnsEnvironment": self.cloudEnvironment };
		
		NSURL *url = [NSURL URLWithString:createRemoteNotificationTokenURL];
		
		[CKContainer sendPOSTRequestTo:url withJSON:postData completionHandler:^(id jsonResponse, NSError *error) {
			if (error != nil) {
				DebugLog(CKLOG_LEVEL_ERR, @"json response: %@ error: %@", jsonResponse, error);
			}
			
			if (jsonResponse[@"webcourierURL"]) {
				NSData* tokenData = [jsonResponse[@"apnsToken"] dataUsingEncoding:NSUTF8StringEncoding];
				[[[NSApplication sharedApplication] delegate] application:[NSApplication sharedApplication] didRegisterForRemoteNotificationsWithDeviceToken:tokenData];
				
				[self longPollAtURL:jsonResponse[@"webcourierURL"]];
			}
			else {
				[[[NSApplication sharedApplication] delegate] application:[NSApplication sharedApplication] didFailToRegisterForRemoteNotificationsWithError:error];
			}
			opCompletionBlock();
		}];
	}];
	[[[CKMediator sharedMediator] queue] addOperation:blockOp];
}


#pragma mark - Web Services

+ (void)sendPOSTRequestTo:(NSURL *)fetchURL withJSON:(id)postData completionHandler:(void (^)(id jsonResponse, NSError *error))completionHandler {
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request addValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPMethod:@"POST"];
	[request setURL:fetchURL];
	
	NSError *jsonError;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postData options:0 error:&jsonError];
	if (jsonError) {
		completionHandler(nil, jsonError);
		return;
	}
	
	[request setHTTPBody:jsonData];
	
	[[[CKContainer downloadSession] dataTaskWithRequest:request completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
		if (error != nil) {
			if (completionHandler) {
				completionHandler(nil, error);
			}
		}
		else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
			NSError* jsonError = nil;
			id jsonObj = nil;
			if (data != nil) {
				jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
				
				if (jsonError) {
					error = jsonError;
				}
				else if ([jsonObj isKindOfClass:[NSDictionary class]] && jsonObj[@"serverErrorCode"]) {
					error = [[NSError alloc] initWithCKErrorDictionary:jsonObj];
				}
			}
			else {
				DebugLog(CKLOG_LEVEL_CRIT, @"If there's no error, there should be data for request: %@ with response: %@", request, response);
			}
			
			if (completionHandler) {
				completionHandler(jsonObj, error);
			}
		}
		else {
			if (completionHandler) {
				completionHandler(nil, error);
			}
		}
	}] resume];
}


+ (void)sendPOSTRequestTo:(NSURL *)uploadDestination withFile:(NSURL *)localFile completionHandler:(void (^)(id jsonResponse, NSError *error))completionHandler {
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request addValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPMethod:@"POST"];
	[request setURL:uploadDestination];
	
	
	[[[CKContainer uploadSession] uploadTaskWithRequest:request fromFile:localFile completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
		if (error != nil) {
			if (completionHandler) {
				completionHandler(nil, error);
			}
		}
		else if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
			
			NSError* jsonError;
			id jsonObj = nil;
			if (data != nil) {
				jsonObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
				
				if (jsonError) {
					error = jsonError;
				}
				else if ([jsonObj isKindOfClass:[NSDictionary class]] && jsonObj[@"serverErrorCode"]) {
					error = [[NSError alloc] initWithCKErrorDictionary:jsonObj];
				}
			}
			else {
				DebugLog(CKLOG_LEVEL_CRIT, @"If there's no error, there should be data for request: %@ with response: %@", request, response);
			}
			
			if (completionHandler) {
				completionHandler(jsonObj, error);
			}
		}
		else {
			if (completionHandler) {
				completionHandler(nil, error);
			}
		}
	}] resume];
}


+ (NSString *)percentEscape:(NSString *)string {
	return [[[[string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"] stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
}

#pragma mark - Long Poll for Push Notifications

- (void)longPollAtURL:(NSString *)urlString {
	urlString = [urlString stringByReplacingOccurrencesOfString:@":443" withString:@""];
	
	DebugLog(CKLOG_LEVEL_DEBUG, @"long polling at: %@", urlString);
	
	NSURL *longPollURL = [NSURL URLWithString:urlString];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setHTTPMethod:@"GET"];
	[request setURL:longPollURL];
	[request setTimeoutInterval:86400];
	
	[NSURLConnection sendAsynchronousRequest:request queue:[[CKMediator sharedMediator] queue] completionHandler:^(NSURLResponse *_Nullable response, NSData *_Nullable data, NSError *_Nullable connectionError) {
		
		NSError* jsonError;
		id jsonObj;
		if (data) {
			jsonObj= [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
		}
		
		if (jsonObj) {
			targetInterval = 0;
			[[[NSApplication sharedApplication] delegate] application:[NSApplication sharedApplication] didReceiveRemoteNotification:jsonObj];
			jsonError = nil; // clear out the error since we're comparing against errors below.
		}
		
		if (!connectionError && !jsonError) {
			[self longPollAtURL:urlString];
		}
		else {
			dispatch_async(dispatch_get_main_queue(), ^{
				// slowly retry every 1, 2, 4, 8 ... seconds up to 1 minute retry intervals
				targetInterval = MAX(1, MIN(60, targetInterval * 2));
				DebugLog(CKLOG_LEVEL_ERR, @"Long poll failed, retrying in: %.2f connectionError:%@ jsonError:%@", targetInterval, connectionError, jsonError);
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(targetInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
					[self longPollAtURL:urlString];
				});
			});
		}
	}];
}

#pragma mark - identity notification change

- (void)cloudIdentityDidChange:(NSNotification *)note {
	if (self.accountStatusCompletionHandler != nil) {
		self.accountStatusCompletionHandler([note.userInfo[CKAccountStatusNotificationUserInfoKey] integerValue], nil);
		self.accountStatusCompletionHandler = nil;
	}
}

@end
