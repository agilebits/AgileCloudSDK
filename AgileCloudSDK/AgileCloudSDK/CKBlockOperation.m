//
//  CKBlockOperation.m
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import "CKBlockOperation.h"

@implementation CKBlockOperation {
	BOOL _executing;
	BOOL _finished;
	void (^_block)(void (^)());
}

- (instancetype)initWithBlock:(void (^)(void (^onComplete)()))block {
	if (self = [super init]) {
		_block = block;
	}
	return self;
}

- (void)setExecuting:(BOOL)executing {
	[self willChangeValueForKey:@"isExecuting"];
	_executing = executing;
	[self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isExecuting {
	return _executing;
}

- (void)setFinished:(BOOL)finished {
	[self willChangeValueForKey:@"isFinished"];
	_finished = finished;
	[self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isFinished {
	return _finished;
}

- (BOOL)asynchronous {
	return YES;
}

- (void)start {
	[self setExecuting:YES];
	dispatch_async(dispatch_get_main_queue(), ^{
		_block(^{
			[self setExecuting:NO];
			[self setFinished:YES];
		});
	});
}

@end
