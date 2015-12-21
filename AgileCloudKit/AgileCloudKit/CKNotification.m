//
//  CKNotification.h
//  CloudKit
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKNotification.h"

@implementation CKNotificationID

+ (BOOL)supportsSecureCoding
{
    return NO;
}

- (instancetype)copyWithZone:(NSZone *)zone {
	return [[[self class] allocWithZone:zone] init];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
	return [[[self class] alloc] init]; // nothing to decode yet - kevin 2015-12-21
}

- (void)encodeWithCoder:(NSCoder *)encoder {
}

@end

@implementation CKNotification

@end

@implementation CKQueryNotification

@end

@implementation CKRecordZoneNotification

@end
