//
//  CKQuery+AgileDictionary.m
//  AgileCloudSDK
//
//  Created by Adam Wulf on 6/22/16.
//  Copyright © 2016 AgileBits. All rights reserved.
//

#import "CKQuery+AgileDictionary.h"
#import "CKFilter_Private.h"
#import "NSSortDescriptor+AgileDictionary.h"

@implementation CKQuery (AgileDictionary)

- (NSDictionary *)asAgileDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:self.recordType forKey:@"recordType"];
    
    NSMutableArray* filterArray = [NSMutableArray array];
    for (CKFilter* filter in self.filters) {
        [filterArray addObject:[filter asAgileDictionary]];
    }
    [dictionary setObject:filterArray forKey:@"filterBy"];
    
    NSMutableArray* sortArray = [NSMutableArray array];
    for (NSSortDescriptor* sort in self.sortDescriptors) {
        [sortArray addObject:[sort asAgileDictionary]];
    }
    [dictionary setObject:sortArray forKey:@"sortBy"];

    return dictionary;
}

@end
