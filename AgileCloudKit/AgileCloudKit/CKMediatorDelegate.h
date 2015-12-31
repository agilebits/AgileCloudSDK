//
//  CKMediatorDelegate.h
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CKMediatorDelegate <NSObject>

- (NSString *)loadSessionToken;

- (void)saveSessionToken:(NSString *)token;


@end
