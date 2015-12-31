//
//  CKBlockOperation.h
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKBlockOperation : NSOperation

- (instancetype)initWithBlock:(void (^)(void (^onComplete)()))block;

@end
