//
//  CKServerChangeToken_Private.h
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgileCloudSDK/CKDatabaseOperation.h>
#import "CKServerChangeToken.h"

@interface CKServerChangeToken (AgilePrivate)

- (instancetype)initWithString:(NSString *)token;

@property(nonatomic, readonly) NSString *token;

@end
