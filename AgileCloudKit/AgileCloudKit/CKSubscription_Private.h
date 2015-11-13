//
//  CKSubscription_Private.h
//  AgileCloudKit
//
//  Created by Adam Wulf on 9/13/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgileCloudKit/CKDatabaseOperation.h>
#import "CKServerChangeToken.h"

@interface CKSubscription ()

- (instancetype)initWithDictionary:(NSDictionary *)dictionary NS_DESIGNATED_INITIALIZER;

- (void)updateWithDictionary:(NSDictionary *)dictionary;

@end
