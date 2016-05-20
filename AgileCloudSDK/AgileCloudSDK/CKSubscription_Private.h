//
//  CKSubscription_Private.h
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgileCloudSDK/CKDatabaseOperation.h>
#import "CKServerChangeToken.h"

@interface CKSubscription ()

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

- (void)updateWithDictionary:(NSDictionary *)dictionary;

@end
