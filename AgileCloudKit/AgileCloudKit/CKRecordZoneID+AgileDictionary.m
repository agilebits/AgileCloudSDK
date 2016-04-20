//
//  CKRecordZoneID+AgileDictionary.m
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import "CKRecordZoneID+AgileDictionary.h"

@implementation CKRecordZoneID (AgileDictionary)

- (NSDictionary *)asAgileDictionary {
	return @{ @"zoneName": self.zoneName,
			  @"ownerName": self.ownerName };
}

@end
