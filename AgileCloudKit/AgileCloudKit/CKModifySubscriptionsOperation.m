//
//  CKModifySubscriptionOperation.h
//  CloudKit
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <AgileCloudKit/CKDatabaseOperation.h>
#import "CKModifySubscriptionsOperation.h"
#import "CKDatabaseOperation_Private.h"
#import "NSArray+AgileMap.h"
#import "CKSubscription+AgileDictionary.h"
#import "CKSubscription_Private.h"
#import "CKDatabase_Private.h"

@implementation CKModifySubscriptionsOperation

- (instancetype)init
{
    return [self initWithSubscriptionsToSave:@[] subscriptionIDsToDelete:@[]];
}

- (instancetype)initWithSubscriptionsToSave:(NSArray /* CKSubscription */ *)subscriptionsToSave subscriptionIDsToDelete:(NSArray /* NSString */ *)subscriptionIDsToDelete
{
    if (self = [super init]) {
        self.subscriptionsToSave = subscriptionsToSave;
        self.subscriptionIDsToDelete = subscriptionIDsToDelete;
    }
    return self;
}

- (void)start
{
    [self setExecuting:YES];

    if ([_subscriptionIDsToDelete count] || [_subscriptionsToSave count]) {
        NSMutableDictionary *savedSubscriptionIDToSubscription = [NSMutableDictionary dictionary];

        NSArray *ops = @[];
        ops = [ops arrayByAddingObjectsFromArray:[_subscriptionIDsToDelete agile_mapUsingBlock:^id(id obj, NSUInteger idx) {
            return @{ @"operationType" : @"delete",
                      @"subscription" : @{ @"subscriptionID" : obj }};
        }]];


        ops = [ops arrayByAddingObjectsFromArray:[_subscriptionsToSave agile_mapUsingBlock:^id(id obj, NSUInteger idx) {

            [savedSubscriptionIDToSubscription setObject:obj forKey:[obj subscriptionID]];

            return @{ @"operationType" : @"create",
                      @"subscription" : [obj asAgileDictionary] };
        }]];

        NSDictionary *requestDictionary = @{ @"operations": ops };

        [self.database sendPOSTRequestTo:@"subscriptions/modify" withJSON:requestDictionary completionHandler:^(id jsonResponse, NSError *error) {
            NSMutableArray* savedSubs = [NSMutableArray array];
            NSMutableArray* deletedSubs = [NSMutableArray array];
            NSMutableDictionary* partialFailures = [NSMutableDictionary dictionary];

            if([jsonResponse isKindOfClass:[NSDictionary class]] && jsonResponse[@"subscriptions"]){
                [jsonResponse[@"subscriptions"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

                    NSString* savedSubID = obj[@"subscriptionID"];
                    CKSubscription* originalSub = savedSubscriptionIDToSubscription[savedSubID];

                    if(originalSub){
                        NSError* recordError = nil;
                        if(obj[@"serverErrorCode"]){
                            recordError = [[NSError alloc] initWithCKErrorDictionary:obj];
                            [partialFailures setObject:recordError forKey:originalSub.subscriptionID];
                        }else{
                            [originalSub updateWithDictionary:obj];
                            [savedSubs addObject:originalSub];
                        }
                    }else if(obj[@"deleted"]){
                        // was it deleted?
                        [deletedSubs addObject:savedSubID];
                    }
                }];
            }else if(!error){
                error = [[NSError alloc] initWithCKErrorDictionary:jsonResponse];
            }

            if(!error && [[partialFailures allKeys] count]){
                NSDictionary* userInfo = @{ @"ContainerID" : self.database.container.containerIdentifier,
                                            @"CKPartialErrors" : partialFailures };
                error = [[NSError alloc] initWithDomain:CKErrorDomain code:CKErrorPartialFailure userInfo:userInfo];
            }

            if(self.modifySubscriptionsCompletionBlock){
                self.modifySubscriptionsCompletionBlock(savedSubs, deletedSubs, error);
            }
        }];

        [self setExecuting:NO];
        [self setFinished:YES];
    } else {
        if (self.modifySubscriptionsCompletionBlock) {
            self.modifySubscriptionsCompletionBlock(@[], @[], nil);
        }
    }
}

@end
