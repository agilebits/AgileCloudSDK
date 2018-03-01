//
//  CKRecord+AgileDictionary.h
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import "CKRecord.h"

@interface CKRecord (AgileDictionary)

+(NSDictionary*) recordFieldDictionaryForValue:(NSObject<CKRecordValue>*)val;

- (NSDictionary *)asAgileDictionary;

@end
