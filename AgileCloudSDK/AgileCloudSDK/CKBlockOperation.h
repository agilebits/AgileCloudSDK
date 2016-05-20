//
//  CKBlockOperation.h
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKBlockOperation : NSOperation

// You MUST call the onComplete block in your block or it won't get removed from the queue - kevin 2016-01-05
- (instancetype)initWithBlock:(void (^)(void (^onComplete)()))block;

@end
