//
//  CKBlockOperation.h
//  AgileCloudKit
//
//  Created by Adam Wulf on 9/18/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKBlockOperation : NSOperation

- (instancetype)initWithBlock:(void (^)(void (^onComplete)()))block;

@end
