//
//  CKServerChangeToken_Private.h
//  AgileCloudKit
//
//  Created by Adam Wulf on 9/11/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgileCloudKit/CKDatabaseOperation.h>
#import "CKServerChangeToken.h"

@interface CKServerChangeToken (AgilePrivate)

- (instancetype)initWithString:(NSString *)token;

@property(nonatomic, readonly) NSString *token;

@end
