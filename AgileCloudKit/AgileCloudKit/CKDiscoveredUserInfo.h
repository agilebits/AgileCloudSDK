//
//  CKDiscoveredUserInfo.h
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKRecordID;

@interface CKDiscoveredUserInfo : NSObject

- (instancetype)init NS_UNAVAILABLE;

@property(nonatomic, readonly, copy) CKRecordID *userRecordID;
@property(nonatomic, readonly, copy) NSString *firstName;
@property(nonatomic, readonly, copy) NSString *lastName;

@end
