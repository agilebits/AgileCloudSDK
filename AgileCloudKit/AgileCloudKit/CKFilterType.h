//
//  AgileDictionary.h
//  AgileCloudKit
//
//  Created by Adam Wulf on 9/14/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CKRecordValue;

@protocol CKFilterType <CKRecordValue, NSCoding>

@optional
- (NSDictionary *)asAgileDictionary;

@end
