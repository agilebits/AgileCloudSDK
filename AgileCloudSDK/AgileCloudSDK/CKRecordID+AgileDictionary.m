//
//  CKRecordID+AgileDictionary.m
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import "CKRecordID+AgileDictionary.h"
#import "CKRecordZoneID.h"

@implementation CKRecordID (AgileDictionary)

- (NSDictionary *)asAgileDictionary {
	return @{ @"recordName": self.recordName,
			  @"zoneID": self.zoneID.zoneName };
}

@end
