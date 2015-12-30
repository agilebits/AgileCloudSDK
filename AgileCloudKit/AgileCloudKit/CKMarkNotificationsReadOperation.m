//
//  CKMarkNotificationsReadOperation.h
//  CloudKit
//
//  Copyright (c) 2015 AgileBits Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgileCloudKit/CKOperation.h>
#import "CKMarkNotificationsReadOperation.h"

@implementation CKMarkNotificationsReadOperation

// this method is not used yet. Substituting init until its needed - kevin 2015-12-21
- (instancetype)initWithNotificationIDsToMarkRead:(NSArray /* CKNotificationID */ *)notificationIDs {
	return [super init];
}

@end
