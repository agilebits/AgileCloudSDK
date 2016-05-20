//
//  NSArray+AgileMap.h
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (AgileMap)

- (NSArray *)agile_mapUsingBlock:(id (^)(id obj, NSUInteger idx))block;

- (NSArray *)agile_mapUsingSelector:(SEL)selector;

@end
