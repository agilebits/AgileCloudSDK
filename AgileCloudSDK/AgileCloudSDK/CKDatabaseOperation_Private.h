//
//  CKDatabaseOperation_Private.h
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import "CKDatabaseOperation.h"

@interface CKDatabaseOperation (AgilePrivate)

// subclasses that implement this should call the operation's completion block with error
- (void)completeWithError:(NSError *)error;

/* If no database is set, [self.container privateCloudDatabase] is used. */
@property(nonatomic, assign, getter=isExecuting) BOOL executing;
@property(nonatomic, assign, getter=isFinished) BOOL finished;

@end
