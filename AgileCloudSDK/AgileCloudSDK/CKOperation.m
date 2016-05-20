//
//  CKOperation.m
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKOperation.h"
#import "CKContainer.h"

@implementation CKOperation


/* If no container is set, [CKContainer defaultContainer] is used */
- (CKContainer *)container {
	if (!_container) {
		return [CKContainer defaultContainer];
	}
	return _container;
}


- (instancetype)init {
	if (self = [super init]) {
	}
	return self;
}

@end
