//
//  CKMediatorDelegate.h
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKMediator;

@protocol CKMediatorDelegate <NSObject>

@required
- (NSString *)loadSessionTokenForMediator:(CKMediator *)mediator;
- (void)mediator:(CKMediator *)mediator saveSessionToken:(NSString *)token;

@optional

- (void)mediator:(CKMediator *)mediator logObject:(id)object at:(SEL)method format:(NSString *)format,... NS_FORMAT_FUNCTION(4,5);

@end
