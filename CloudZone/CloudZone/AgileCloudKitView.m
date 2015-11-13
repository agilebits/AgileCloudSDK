//
//  AgileCloudKitView.m
//  CloudZone
//
//  Created by Adam Wulf on 9/5/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import "AgileCloudKitView.h"
#import <AgileCloudKit/AgileCloudKit.h>

@interface AgileCloudKitView () <CKMediatorDelegate>

@end

@implementation AgileCloudKitView {
    NSButton *_logoutButton;
    NSButton *_loginButton;
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[CKMediator sharedMediator] setDelegate:self];
        });

        _logoutButton = [[NSButton alloc] initWithFrame:NSMakeRect(self.bounds.size.width - 120, 10, 100, 20)];
        [_logoutButton setButtonType:NSMomentaryPushInButton];
        [_logoutButton setTitle:@"Log out"];
        [_logoutButton setAutoresizingMask:NSViewMinXMargin | NSViewMaxYMargin];
        [_logoutButton setTarget:self];
        [_logoutButton setAction:@selector(didClickLogoutButton)];
        [_logoutButton setHidden:YES];
        [self addSubview:_logoutButton];

        _loginButton = [[NSButton alloc] initWithFrame:NSMakeRect(self.bounds.size.width - 120, 10, 100, 20)];
        [_loginButton setButtonType:NSMomentaryPushInButton];
        [_loginButton setTitle:@"Log in"];
        [_loginButton setAutoresizingMask:NSViewMinXMargin | NSViewMaxYMargin];
        [_loginButton setTarget:self];
        [_loginButton setAction:@selector(didClickLoginButton)];
        [_loginButton setHidden:YES];
        [self addSubview:_loginButton];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cloudKitIdentityDidChange:) name:NSUbiquityIdentityDidChangeNotification object:nil];
    }
    return self;
}

- (void)startTests
{
    [super startTests];
}


- (void)didClickLogoutButton
{
    [[CKMediator sharedMediator] logout];
}

- (void)didClickLoginButton
{
    [[CKMediator sharedMediator] login];
}

#pragma mark - Notifications

- (void)cloudKitIdentityDidChange:(NSNotification *)note
{
    if ([note.userInfo[@"accountStatus"] integerValue] == CKAccountStatusAvailable) {
        _logoutButton.hidden = NO;
        _loginButton.hidden = YES;
    } else {
        _logoutButton.hidden = YES;
        _loginButton.hidden = NO;
    }

    CKContainer *defCont = [CKContainer defaultContainer];
    NSLog(@"container 1: %@", defCont.containerIdentifier);
}

#pragma mark - CKMediatorDelegate

- (void)saveSessionToken:(NSString *)token
{
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"AgileCloudKit_sessionToken"];
}

- (NSString *)loadSessionToken
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"AgileCloudKit_sessionToken"];
}

@end
