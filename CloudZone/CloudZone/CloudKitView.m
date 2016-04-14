//
//  CloudKitView.m
//  CloudZone
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import "CloudKitView.h"
#import "Constants.h"
#import CloudKitImport

@implementation CloudKitView

- (BOOL)isFlipped
{
    return YES;
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        _startTestsButton = [[NSButton alloc] initWithFrame:NSMakeRect(self.bounds.size.width - 120, 40, 100, 20)];
        [_startTestsButton setButtonType:NSMomentaryPushInButton];
        [_startTestsButton setTitle:@"Start Tests"];
        [_startTestsButton setAutoresizingMask:NSViewMinXMargin | NSViewMaxYMargin];
        [self addSubview:_startTestsButton];

        _subscribeButton = [[NSButton alloc] initWithFrame:NSMakeRect(self.bounds.size.width - 120, 70, 100, 20)];
        [_subscribeButton setButtonType:NSMomentaryPushInButton];
        [_subscribeButton setTitle:@"Subscribe"];
        [_subscribeButton setAutoresizingMask:NSViewMinXMargin | NSViewMaxYMargin];
        [self addSubview:_subscribeButton];

        _addRecordButton = [[NSButton alloc] initWithFrame:NSMakeRect(self.bounds.size.width - 120, 100, 100, 20)];
        [_addRecordButton setButtonType:NSMomentaryPushInButton];
        [_addRecordButton setTitle:@"Add Record"];
        [_addRecordButton setAutoresizingMask:NSViewMinXMargin | NSViewMaxYMargin];
        [self addSubview:_addRecordButton];
		
		_recordTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(20, 40, 200, 22)];
		[self addSubview:_recordTextField];
    }

    return self;
}

@end
