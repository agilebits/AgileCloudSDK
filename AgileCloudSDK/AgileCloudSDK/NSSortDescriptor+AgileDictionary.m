//
//  NSSortDescriptor+AgileDictionary.m
//  AgileCloudSDK
//
//  Created by Adam Wulf on 6/22/16.
//  Copyright © 2016 AgileBits. All rights reserved.
//

#import "NSSortDescriptor+AgileDictionary.h"

@implementation NSSortDescriptor (AgileDictionary)

- (NSDictionary *)asAgileDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:self.key forKey:@"fieldName"];
    // make sure booleans encode as integers
    [dictionary setObject:[NSNumber numberWithInteger:self.ascending] forKey:@"ascending"];
    
    return dictionary;
}

@end
