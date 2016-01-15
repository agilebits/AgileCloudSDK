//
//  CKMediatorDelegate.h
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>

// These match ASL_LEVELs defined in asl.h
#define CKLOG_LEVEL_EMERG   0
#define CKLOG_LEVEL_ALERT   1
#define CKLOG_LEVEL_CRIT    2
#define CKLOG_LEVEL_ERR     3
#define CKLOG_LEVEL_WARNING 4
#define CKLOG_LEVEL_NOTICE  5
#define CKLOG_LEVEL_INFO    6
#define CKLOG_LEVEL_DEBUG   7

@class CKMediator;

@protocol CKMediatorDelegate <NSObject>

@required
- (NSString *)loadSessionTokenForMediator:(CKMediator *)mediator;
- (void)mediator:(CKMediator *)mediator saveSessionToken:(NSString *)token;

@optional

- (void)mediator:(CKMediator *)mediator logLevel:(int)level object:(id)object at:(SEL)method format:(NSString *)format,... NS_FORMAT_FUNCTION(5,6);

@end
