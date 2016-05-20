//
//  CKDatabaseOperation.h
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits Inc. All rights reserved.
//

#import "CKOperation.h"

@class CKDatabase;

@interface CKDatabaseOperation : CKOperation

/* If no database is set, [self.container privateCloudDatabase] is used. */
@property(nonatomic, strong) CKDatabase *database;

@end
