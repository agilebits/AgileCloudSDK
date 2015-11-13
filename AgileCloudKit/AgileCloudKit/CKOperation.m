//
//  CKOperation.h
//  CloudKit
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgileCloudKit/AgileCloudKit.h>

@implementation CKOperation


/* If no container is set, [CKContainer defaultContainer] is used */
- (CKContainer *)container
{
    if (!_container) {
        return [CKContainer defaultContainer];
    }
    return _container;
}


- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

@end
