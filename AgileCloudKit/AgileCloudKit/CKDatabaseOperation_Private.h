//
//  CKDatabaseOperation_Private.h
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

@interface CKDatabaseOperation (AgilePrivate)

/* If no database is set, [self.container privateCloudDatabase] is used. */
@property(nonatomic, assign, getter=isExecuting) BOOL executing;
@property(nonatomic, assign, getter=isFinished) BOOL finished;

@end
