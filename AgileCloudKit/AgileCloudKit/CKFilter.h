//
//  CKFilter.h
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgileCloudKit/AgileCloudKit.h>

extern NSString *const CK_EQUALS;
extern NSString *const CK_NOT_EQUALS;
extern NSString *const CK_LESS_THAN;
extern NSString *const CK_LESS_THAN_OR_EQUALS;
extern NSString *const CK_GREATER_THAN;
extern NSString *const CK_GREATER_THAN_OR_EQUALS;
extern NSString *const CK_NEAR;
extern NSString *const CK_CONTAINS_ALL_TOKENS;
extern NSString *const CK_IN;
extern NSString *const CK_NOT_IN;
extern NSString *const CK_CONTAINS_ANY_TOKENS;
extern NSString *const CK_LIST_CONTAINS;
extern NSString *const CK_NOT_LIST_CONTAINS;
extern NSString *const CK_NOT_LIST_CONTAINS_ANY;
extern NSString *const CK_BEGINS_WITH;
extern NSString *const CK_NOT_BEGINS_WITH;
extern NSString *const CK_LIST_MEMBER_BEGINS_WITH;
extern NSString *const CK_NOT_LIST_MEMBER_BEGINS_WITH;
extern NSString *const CK_LIST_CONTAINS_ALL;
extern NSString *const CK_NOT_LIST_CONTAINS_ALL;

@class CKRecordZoneID;

@interface CKFilter : NSObject <NSSecureCoding, NSCopying>

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithComparator:(NSString *)comparator fieldName:(NSString *)fieldName fieldType:(NSString *)fieldType fieldValue:(NSObject<CKFilterType, NSCoding> *)fieldValue;

@property(nonatomic, readonly) NSString *comparator;
@property(nonatomic, readonly) NSString *fieldName;
@property(nonatomic, readonly) NSString *fieldType;
@property(nonatomic, readonly) NSObject<CKFilterType> *fieldValue;


@end
