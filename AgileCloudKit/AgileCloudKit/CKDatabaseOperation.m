//
//  CKDatabaseOperation.m
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits Inc. All rights reserved.
//

#import <AgileCloudKit/AgileCloudKit.h>
#import "CKDatabaseOperation.h"
#import "CKMediator_Private.h"
#import "Defines.h"

@implementation CKDatabaseOperation {
	BOOL _executing;
	BOOL _finished;
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

- (CKDatabase *)database {
	if (!_database) {
		_database = [[CKContainer defaultContainer] privateCloudDatabase];
	}
	return _database;
}

@end
