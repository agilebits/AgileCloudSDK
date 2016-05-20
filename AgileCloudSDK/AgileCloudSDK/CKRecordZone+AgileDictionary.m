//
//  CKRecordZone+AgileDictionary.m
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import "CKRecordZone+AgileDictionary.h"
#import "CKRecordZoneID+AgileDictionary.h"

@implementation CKRecordZone (AgileDictionary)

- (NSDictionary *)asAgileDictionary {
	return @{ @"zoneID": [self.zoneID asAgileDictionary] };
}

@end
