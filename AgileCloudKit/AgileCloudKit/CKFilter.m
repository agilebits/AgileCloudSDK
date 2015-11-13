//
//  CKFilter.m
//  AgileCloudKit
//
//  Created by Adam Wulf on 9/14/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import "CKFilter.h"
#import "CKRecord_Private.h"

NSString *const CK_EQUALS = @"EQUALS";
NSString *const CK_NOT_EQUALS = @"NOT_EQUALS";
NSString *const CK_LESS_THAN = @"LESS_THAN";
NSString *const CK_LESS_THAN_OR_EQUALS = @"LESS_THAN_OR_EQUALS";
NSString *const CK_GREATER_THAN = @"GREATER_THAN";
NSString *const CK_GREATER_THAN_OR_EQUALS = @"GREATER_THAN_OR_EQUALS";
NSString *const CK_NEAR = @"NEAR";
NSString *const CK_CONTAINS_ALL_TOKENS = @"CONTAINS_ALL_TOKENS";
NSString *const CK_IN = @"IN";
NSString *const CK_NOT_IN = @"NOT_IN";
NSString *const CK_CONTAINS_ANY_TOKENS = @"CONTAINS_ANY_TOKENS";
NSString *const CK_LIST_CONTAINS = @"LIST_CONTAINS";
NSString *const CK_NOT_LIST_CONTAINS = @"NOT_LIST_CONTAINS";
NSString *const CK_NOT_LIST_CONTAINS_ANY = @"NOT_LIST_CONTAINS_ANY";
NSString *const CK_BEGINS_WITH = @"BEGINS_WITH";
NSString *const CK_NOT_BEGINS_WITH = @"NOT_BEGINS_WITH";
NSString *const CK_LIST_MEMBER_BEGINS_WITH = @"LIST_MEMBER_BEGINS_WITH";
NSString *const CK_NOT_LIST_MEMBER_BEGINS_WITH = @"NOT_LIST_MEMBER_BEGINS_WITH";
NSString *const CK_LIST_CONTAINS_ALL = @"LIST_CONTAINS_ALL";
NSString *const CK_NOT_LIST_CONTAINS_ALL = @"NOT_LIST_CONTAINS_ALL";

static NSArray *allowedComparators;

@implementation CKFilter

- (instancetype)initWithComparator:(NSString *)comparator fieldName:(NSString *)fieldName fieldType:(NSString *)fieldType fieldValue:(NSObject<CKFilterType, NSCoding> *)fieldValue
{
    if (self = [super init]) {
        self.comparator = comparator;
        _fieldName = fieldName;
        _fieldType = fieldType;
        _fieldValue = fieldValue;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary inZone:(CKRecordZoneID *)zoneID
{
    if (self = [super init]) {
        self.comparator = dictionary[@"comparator"];
        _fieldName = dictionary[@"fieldName"];
        _fieldType = dictionary[@"fieldValue"][@"type"];
        _fieldValue = (NSObject<CKFilterType> *)[CKRecord recordValueFromDictionary:dictionary[@"fieldValue"] inZone:zoneID];
    }
    return self;
}

- (void)setComparator:(NSString *)comparator
{
    if (![allowedComparators containsObject:comparator]) {
        @throw [NSException exceptionWithName:@"CKException" reason:[NSString stringWithFormat:@"%@ is not a valid comparator. Allowed values are %@", comparator, allowedComparators] userInfo:nil];
    }
    _comparator = comparator;
}

- (NSDictionary *)asAgileDictionary
{
    return @{ @"comparator": _comparator,
              @"fieldName": _fieldName,
              @"fieldValue": @{@"type": _fieldType,
                               @"value": [_fieldValue respondsToSelector:@selector(asAgileDictionary)] ? [_fieldValue asAgileDictionary] : _fieldValue} };
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_comparator forKey:@"comparator"];
    [aCoder encodeObject:_fieldName forKey:@"fieldName"];
    [aCoder encodeObject:_fieldType forKey:@"fieldType"];
    [aCoder encodeObject:NSStringFromClass([_fieldValue class]) forKey:@"valueClass"];
    [aCoder encodeObject:_fieldValue forKey:@"fieldValue"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.comparator = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"comparator"];
        _fieldName = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"fieldName"];
        _fieldType = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"fieldType"];
        NSString *cName = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"valueClass"];
        _fieldValue = [aDecoder decodeObjectOfClass:NSClassFromString(cName) forKey:@"fieldValue"];
    }
    return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithDictionary:[self asAgileDictionary]];
}

#pragma mark - Loading

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allowedComparators = @[CK_EQUALS,
                               CK_NOT_EQUALS,
                               CK_LESS_THAN,
                               CK_LESS_THAN_OR_EQUALS,
                               CK_GREATER_THAN,
                               CK_GREATER_THAN_OR_EQUALS,
                               CK_NEAR,
                               CK_CONTAINS_ALL_TOKENS,
                               CK_IN,
                               CK_NOT_IN,
                               CK_CONTAINS_ANY_TOKENS,
                               CK_LIST_CONTAINS,
                               CK_NOT_LIST_CONTAINS,
                               CK_NOT_LIST_CONTAINS_ANY,
                               CK_BEGINS_WITH,
                               CK_NOT_BEGINS_WITH,
                               CK_LIST_MEMBER_BEGINS_WITH,
                               CK_NOT_LIST_MEMBER_BEGINS_WITH,
                               CK_LIST_CONTAINS_ALL,
                               CK_NOT_LIST_CONTAINS_ALL];
    });
}

@end
