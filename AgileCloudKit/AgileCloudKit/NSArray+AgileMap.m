//
//  NSArray+AgileMap.m
//  AgileCloudKit
//
//  Created by Adam Wulf on 9/10/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import "NSArray+AgileMap.h"

@implementation NSArray (AgileMap)

- (NSArray *)agile_mapUsingBlock:(id (^)(id obj, NSUInteger idx))block
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];

    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id mappedObj = block(obj, idx);
        if(mappedObj){
            [result addObject:mappedObj];
        }
    }];

    return result;
}

- (NSArray *)agile_mapUsingSelector:(SEL)selector
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];

    [self enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [result addObject:[obj performSelector:selector]];
#pragma clang diagnostic pop
    }];

    return result;
}

@end
