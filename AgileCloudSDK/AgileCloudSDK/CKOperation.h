//
//  CKOperation.h
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKContainer;

@interface CKOperation : NSOperation

- (instancetype)init NS_DESIGNATED_INITIALIZER;

/* All CKOperations default to self.qualityOfService == NSOperationQualityOfServiceUserInitiated */

/* If no container is set, [CKContainer defaultContainer] is used */
@property(nonatomic, strong) CKContainer *container;

/* If set, network traffic will happen on a background NSURLSession.
 Defaults to (NSOperationQualityOfServiceBackground == self.qualityOfService) */
@property(nonatomic, assign) BOOL usesBackgroundSession;

/* Defaults to YES */
@property(nonatomic, assign) BOOL allowsCellularAccess;

@end
