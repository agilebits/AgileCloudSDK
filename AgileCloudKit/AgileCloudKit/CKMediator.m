//
//  CKMediator.m
//  AgileCloudKit
//
//  Created by Adam Wulf on 8/23/15.
//  Copyright (c) 2015 Adam Wulf. All rights reserved.
//

#import "CKMediator.h"
#import "CKMediator_Private.h"
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "CKContainer_Private.h"
#import "Defines.h"

#define CloudKitJSURL [NSURL URLWithString:@"https://cdn.apple-cloudkit.com/ck/1/cloudkit.js"]

NSString *const kAgileCloudKitInitializedNotification = @"kAgileCloudKitInitializedNotification";

@interface CKMediator () <WebResourceLoadDelegate, WebFrameLoadDelegate, WebPolicyDelegate, WebUIDelegate>

@end

@implementation CKMediator {
    JSContext *_context;
    NSOperationQueue *_urlQueue;
    NSTimeInterval _targetInterval;
}

@synthesize delegate;
@synthesize cloudKitWebView;
@synthesize isInitialized;

static CKMediator *_mediator;

+ (CKMediator *)sharedMediator
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mediator = [[[CKMediator class] alloc] init];
    });
    return _mediator;
}

- (instancetype)init
{
    if (self = [super init]) {
        _containerProperties = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CloudKitJSContainers"];
        // each container contains keys for: CloudKitJSContainerName, CloudKitJSAPIToken, CloudKitJSAPIToken

        // shared operation queue for all cloudkit operations
        _queue = [[NSOperationQueue alloc] init];
        _queue.suspended = YES;

        _urlQueue = [[NSOperationQueue alloc] init];

        // user's token, if any
        _sessionToken = [self loadSessionToken];

        dispatch_async(dispatch_get_main_queue(), ^{
            // setup the WebView that we'll use to host the CloudKitJS
            cloudKitWebView = [[WebView alloc] initWithFrame:NSMakeRect(0, 40, 300, 100)];
            cloudKitWebView.resourceLoadDelegate = self;
            cloudKitWebView.frameLoadDelegate = self;
            cloudKitWebView.policyDelegate = self;
            cloudKitWebView.UIDelegate = self;

            // load in our bootstrap HTML to get CloudKitJS loaded
            [self bootstrapCloudKitJS];
        });

    }
    return self;
}

- (void)bootstrapCloudKitJS
{
    NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [myBundle URLForResource:@"test" withExtension:@"html"];
    if (url) {
        [[cloudKitWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

- (JSContext *)context
{
    return _context;
}

- (NSDictionary *)infoForContainerID:(NSString *)containerID
{
    for (NSDictionary *container in _containerProperties) {
        if ([container[@"CloudKitJSContainerName"] isEqualToString:containerID]) {
            return container;
        }
    }
    return nil;
}

- (void)setDelegate:(NSObject<CKMediatorDelegate> *)_delegate
{
    if (delegate != _delegate) {
        delegate = _delegate;
        _sessionToken = [delegate loadSessionToken];
    }
}

#pragma mark - Save and Load the token

- (NSString *)loadSessionToken
{
    if (delegate) {
        return [delegate loadSessionToken];
    } else {
        return _sessionToken;
    }
}

- (void)saveSessionToken:(NSString *)token
{
    _sessionToken = token;
    if (delegate) {
        return [delegate saveSessionToken:token];
    }
}

#pragma mark - Auth with URL

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
	NSURLComponents *urlComponents = [NSURLComponents componentsWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
	NSArray *queryItems = urlComponents.queryItems;
	for (NSURLQueryItem *queryItem in queryItems) {
		if ([queryItem.name isEqualToString:@"ckSession"]) {
			[self saveSessionToken:queryItem.value];
			[self setupAuth];
		}
	}
}

#pragma mark - WebFrameLoadDelegate

- (void)webView:(WebView *)webView didCreateJavaScriptContext:(JSContext *)context forFrame:(WebFrame *)frame
{
    // we've got the context from the webview:
    _context = context;

    // re-experiment with JSContext instead of webview
    [self setupContext:_context];
}

- (void)webView:(WebView *)sender resource:(id)identifier didFailLoadingWithError:(NSError *)error fromDataSource:(WebDataSource *)dataSource
{
    DebugLog(@"failed: %@ with: %@", identifier, error);
    dispatch_async(dispatch_get_main_queue(), ^{
        _targetInterval = MAX(1, MIN(60, _targetInterval * 2));
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_targetInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self bootstrapCloudKitJS];
        });
    });
}

#pragma mark - JSContext

//
// Loads the CloudKitJS asynchronously from Apple's URL
// TODO: cache the last successful fetch locally,
// and then periodically update that local cache. that way
// for app launch 2+ we can just load the local cache immediatley
// with no delay.
- (void)loadCloudKitJSAsync
{
    __block NSString *cloudjs;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        cloudjs = [NSString stringWithContentsOfURL:CloudKitJSURL encoding:NSUTF8StringEncoding error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_context evaluateScript:cloudjs withSourceURL:CloudKitJSURL];
        });
    });
}


// When an auth token changes,
// this block will re-fetch the
// active user from cloudkitjs
// and signal out to ObjC using URLs
- (void)setupAuth
{
	if ([NSThread isMainThread] == NO) {
		dispatch_sync(dispatch_get_main_queue(), ^{
			[self setupAuth];
		});
		return;
	}

	for (NSDictionary *container in _containerProperties) {
        NSString *containerID = container[@"CloudKitJSContainerName"];
        [[[_context evaluateScript:[NSString stringWithFormat:@"CloudKit.getContainer('%@').setUpAuth()", containerID]] invokeMethod:@"then" withArguments:@[^(id response) {
            if(response && ![[NSNull null] isEqual:response]){
                DebugLog(@"logged in %@ :%@", containerID, response);
                [[NSNotificationCenter defaultCenter] postNotificationName:NSUbiquityIdentityDidChangeNotification object:self userInfo:@{ @"accountStatus" : @(CKAccountStatusAvailable) }];
            }else{
                DebugLog(@"logged out %@ :%@", containerID, response);
                [[NSNotificationCenter defaultCenter] postNotificationName:NSUbiquityIdentityDidChangeNotification object:self userInfo:@{ @"accountStatus" : @(CKAccountStatusNoAccount) }];
            }
            _queue.suspended = NO;
        }]] invokeMethod:@"catch"
            withArguments:@[^(NSDictionary *err) {
            DebugLog(@"err: %@", err);
            }]];
    }
}

//
// Setup the JSContext to interact with CloudKitJS.
// Important places to tie-in:
// 1. fetch/save auth token
// 2. load cloudKitJS config
// 3. URL listeners for events
- (void)setupContext:(JSContext *)context
{
    // track exceptions and logs from the JSContext
    context[@"window"][@"doLog"] = ^(id str) {
        DebugLog(@"CloudKit Log: %@", [str description]);
    };
    [context setExceptionHandler:^(JSContext *c, JSValue *ex) {
        DebugLog(@"Exception in %@: %@", c, ex);
        @throw [NSException exceptionWithName:@"AgileCloudKitException" reason:[NSString stringWithFormat:@"JS Exception: %@", ex] userInfo:nil];
    }];

    // These blocks will save or load the user's
    // session token from our permanent store
    context[@"window"][@"getTokenBlock"] = ^NSString *(id containerId)
    {
        return _sessionToken;
    };
    context[@"window"][@"putTokenBlock"] = ^(id containerId, id token) {
        if([token isKindOfClass:[NSNull class]]){
            [self saveSessionToken:nil];
            [self setupAuth];
        }else{
            [self saveSessionToken:token];
        }
    };

    //
    // configure CloudKitJS with our container ID
    // and authentication steps, etc
    void (^loadConfig)() = ^{
        NSError* err1;
        NSError* err2;
        NSURL* configURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"config-format" withExtension:@"js"];
        NSString* configFormat = [NSString stringWithContentsOfURL:configURL encoding:NSUTF8StringEncoding error:&err1];

        NSURL* containerConfigURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"container-config-format" withExtension:@"json"];
        NSString* containerConfigFormat = [NSString stringWithContentsOfURL:containerConfigURL encoding:NSUTF8StringEncoding error:&err2];

        if(err1 || err2){
            @throw [NSException exceptionWithName:@"AgileCloudKitConfigException" reason:@"Could not load config for AgileCloudKit" userInfo:@{ @"error1" : err1, @"error2" : err2  }];
        }


        if(![_containerProperties count]){
            DebugLog(@"***********************************************");
            DebugLog(@"AgileCloudKit configuration error. Please check your Info.plist");
            DebugLog(@"***********************************************");
        }else{

            NSString* containerConfigStr = @"";
            for (NSDictionary* containerConfig in _containerProperties){
                // each container contains keys for: CloudKitJSContainerName, CloudKitJSAPIToken, CloudKitJSEnvironment
                NSString* configuration = [NSString stringWithFormat:containerConfigFormat, containerConfig[@"CloudKitJSContainerName"], containerConfig[@"CloudKitJSAPIToken"], containerConfig[@"CloudKitJSEnvironment"], _sessionToken];
                if([containerConfigStr length]){
                    containerConfigStr = [NSString stringWithFormat:@"%@,%@", containerConfigStr, configuration];
                }else{
                    containerConfigStr = configuration;
                }
            }

            NSString* configuration = [NSString stringWithFormat:configFormat, containerConfigStr];
            [context evaluateScript:configuration];
        }
    };

    // add blocks to the context and listen for events:
    // when cloudkit loads:
    // load the config, setupAuth to determine if we're
    // logged in or out, and notify everyone
    // that we're ready to roll
    [[context evaluateScript:@"window"] invokeMethod:@"addEventListener" withArguments:@[@"cloudkitloaded", ^() {
        loadConfig();
        [self setupAuth];
        isInitialized = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:kAgileCloudKitInitializedNotification object:self];
    }]];

    // If CloudKitJS tries to trigger a window.open()
    // to login the user, we should pass that on to Safari
    context[@"window"][@"open"] = ^(id url) {
        DebugLog(@"CloudKitJS Context requested to open URL: %@", url);
    };
}

#pragma mark - Actions

- (IBAction)login
{
    [self getLoginURLWithCompletionBlock:^(NSURL *loginURL, NSError *error) {
        [[NSWorkspace sharedWorkspace] openURL:loginURL];
    }];
}

- (IBAction)logout
{
    _sessionToken = nil;
    [self.delegate saveSessionToken:nil];
    [self setupAuth];
}

#pragma mark - Web Service Request

- (void)getLoginURLWithCompletionBlock:(void (^)(NSURL *loginURL, NSError *error))onComplete
{
    CKContainer *defContainer = [CKContainer defaultContainer];

    NSString *fetchCurrentUserURL = [NSString stringWithFormat:@"https://api.apple-cloudkit.com/database/1/%@/%@/private/users/current?ckAPIToken=%@",
                                                               defContainer.cloudKitContainerName,
                                                               defContainer.cloudKitEnvironment,
                                                               defContainer.cloudKitAPIToken];
    NSURLRequest *pendingRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:fetchCurrentUserURL]];
    [NSURLConnection sendAsynchronousRequest:pendingRequest queue:_urlQueue completionHandler:^(NSURLResponse *_Nullable response, NSData *_Nullable data, NSError *_Nullable connectionError) {

        if(connectionError){
            onComplete(nil, connectionError);
        }

        NSError* error;
        NSDictionary * parsedData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

        if(error){
            onComplete(nil, error);
        }else{
            NSString* redirectURL = parsedData[@"redirectURL"];
            NSURL* loginURL = nil;
            if(redirectURL){
                loginURL = [NSURL URLWithString:parsedData[@"redirectURL"]];
            }

            if(loginURL){
                onComplete(loginURL, nil);
            }else{
                onComplete(nil, [NSError errorWithDomain:CKErrorDomain code:NSIntegerMax userInfo:nil]);
            }
        }
    }];
}

#pragma mark - Remote Notifications

- (void)registerForRemoteNotifications {
    for (NSDictionary *containerProps in _containerProperties) {
        [[CKContainer containerWithIdentifier:containerProps[@"CloudKitJSContainerName"]] registerForRemoteNotifications];
    }
}

@end
