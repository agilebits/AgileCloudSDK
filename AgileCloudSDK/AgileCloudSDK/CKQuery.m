//
//  CKQuery.m
//  AgileCloudSDK
//
//  Created by Adam Wulf on 6/22/16.
//  Copyright © 2016 AgileBits. All rights reserved.
//

#import "CKQuery.h"

@implementation CKQuery

- (instancetype)initWithRecordType:(NSString *)recordType filters:(NSArray<CKFilter *>*)filters{
    if(self = [super init]){
        _filters = [filters copy];
        _recordType = recordType;
    }
    return self;
}

@end
