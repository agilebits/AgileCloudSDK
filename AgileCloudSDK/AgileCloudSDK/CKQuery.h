//
//  CKQuery.h
//  AgileCloudSDK
//
//  Created by Adam Wulf on 6/22/16.
//  Copyright © 2016 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKFilter.h"

NS_ASSUME_NONNULL_BEGIN
NS_CLASS_AVAILABLE(10_10, 8_0)
@interface CKQuery : NSObject <NSSecureCoding, NSCopying>

/*
 
 Only AND compound predicates are allowed.
 
 Key names must begin with either an upper or lower case character ([a-zA-Z]) and may be followed by characters, numbers, or underscores ([0-9a-zA-Z_]). Keypaths may only resolve to the currently evaluated object, so the '.' character is not allowed in key names.
 
 A limited subset of classes are allowed as predicate arguments:
 NSString
 NSDate
 NSData
 NSNumber
 NSArray
 CKReference
 CKRecord
 CLLocation
 
 Any other class as an argument will result in an error when executing the query.
 
 */

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithRecordType:(NSString *)recordType predicate:(NSPredicate *)predicate NS_UNAVAILABLE;

- (instancetype)initWithRecordType:(NSString *)recordType filters:(NSArray<CKFilter *>*)filters NS_DESIGNATED_INITIALIZER;

@property (nonatomic, readonly, copy) NSString *recordType;
@property (nonatomic, readonly, copy) NSArray<CKFilter *>*filters;

@property (nonatomic, copy, nullable) NSArray <NSSortDescriptor *> *sortDescriptors;

@end
NS_ASSUME_NONNULL_END
