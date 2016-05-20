//
//  AgileCloudSDKView
//  CloudZone
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import "AgileCloudSDKView.h"
#import <AgileCloudSDK/AgileCloudSDK.h>

@interface AgileCloudSDKView ()

@end

@implementation AgileCloudSDKView

- (instancetype)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        _logoutButton = [[NSButton alloc] initWithFrame:NSMakeRect(self.bounds.size.width - 120, 10, 100, 20)];
        [_logoutButton setButtonType:NSMomentaryPushInButton];
        [_logoutButton setTitle:@"Log out"];
        [_logoutButton setAutoresizingMask:NSViewMinXMargin | NSViewMaxYMargin];
        [_logoutButton setHidden:YES];
        [self addSubview:_logoutButton];

        _loginButton = [[NSButton alloc] initWithFrame:NSMakeRect(self.bounds.size.width - 120, 10, 100, 20)];
        [_loginButton setButtonType:NSMomentaryPushInButton];
        [_loginButton setTitle:@"Log in"];
        [_loginButton setAutoresizingMask:NSViewMinXMargin | NSViewMaxYMargin];
        [_loginButton setHidden:YES];
        [self addSubview:_loginButton];

    }
    return self;
}

@end
