//
//  CKDatabaseOperation.h
//  CloudKit
//
//  Copyright (c) 2014 AgileBits Inc. All rights reserved.
//

#import <AgileCloudKit/CKOperation.h>

@class CKDatabase;

@interface CKDatabaseOperation : CKOperation

/* If no database is set, [self.container privateCloudDatabase] is used. */
@property(nonatomic, strong) CKDatabase *database;

@end
