//
//  ViewController.m
//  CloudZone
//
//  Created by Adam Wulf on 8/22/15.
//  Copyright (c) 2015 Adam Wulf. All rights reserved.
//

#import "ViewController.h"
#import "CloudKitView.h"
#import "Constants.h"
#import CloudKitImport

#ifdef AGILECLOUDKIT
#import "AgileCloudKitView.h"
#endif

@interface ViewController ()

@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

#ifdef AGILECLOUDKIT
    AgileCloudKitView *agileView = [[AgileCloudKitView alloc] initWithFrame:self.view.bounds];
    agileView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.view addSubview:agileView];
#else
    CloudKitView *cloudKitView = [[CloudKitView alloc] initWithFrame:self.view.bounds];
    cloudKitView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.view addSubview:cloudKitView];
#endif
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

@end
