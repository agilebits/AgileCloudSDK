//
//  CKFilterType.h
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CKRecordValue;

@protocol CKFilterType <CKRecordValue, NSCoding>

@optional
- (NSDictionary *)asAgileDictionary;

@end
