//
//  CKMarkNotificationsReadOperation.h
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKOperation.h"

@interface CKMarkNotificationsReadOperation : CKOperation

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithNotificationIDsToMarkRead:(NSArray /* CKNotificationID */ *)notificationIDs NS_DESIGNATED_INITIALIZER;

@property(nonatomic, copy) NSArray /* CKNotificationID */ *notificationIDs;

@property(nonatomic, copy) void (^markNotificationsReadCompletionBlock)(NSArray /* CKNotificationID */ *notificationIDsMarkedRead, NSError *operationError);

@end
