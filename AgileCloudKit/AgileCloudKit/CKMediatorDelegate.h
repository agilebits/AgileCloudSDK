//
//  CKMediatorDelegate.h
//  AgileCloudKit
//
//  Created by Adam Wulf on 9/5/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CKMediatorDelegate <NSObject>

- (NSString *)loadSessionToken;

- (void)saveSessionToken:(NSString *)token;


@end
