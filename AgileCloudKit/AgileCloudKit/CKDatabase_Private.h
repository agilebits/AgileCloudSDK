//
//  CKDatabase_Private.h
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import <AgileCloudKit/AgileCloudKit.h>

@interface CKDatabase (Private)

@property(nonatomic, readonly) CKContainer *container;

- (void)sendPOSTRequestTo:(NSString *)fragment withJSON:(id)postData completionHandler:(void (^)(id jsonResponse, NSError *error))completionHandler;

@end
