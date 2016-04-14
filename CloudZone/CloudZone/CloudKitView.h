//
//  CloudKitView.h
//  CloudZone
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CloudKitView : NSView

@property (nonatomic, strong) NSButton *subscribeButton;
@property (nonatomic, strong) NSButton *startTestsButton;
@property (nonatomic, strong) NSButton *addRecordButton;
@property (nonatomic, strong) NSTextField *recordTextField;

- (void)startTests;

- (void)listenForPushNotifications;


@end
