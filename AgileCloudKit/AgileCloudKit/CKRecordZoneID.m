//
//  CKRecordZoneID.h
//  CloudKit
//
//  Copyright (c) 2014 AgileBits Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKRecordZoneID.h"
#import "Defines.h"
#import "CKRecordZoneID_Private.h"
#import "CKContainer.h"

@implementation CKRecordZoneID

- (instancetype)init
{
    @throw kInvalidMethodException;
}

- (instancetype)initWithZoneName:(NSString *)zoneName
{
    return [self initWithZoneName:zoneName ownerName:nil];
}

- (instancetype)initWithZoneName:(NSString *)zoneName ownerName:(NSString *)ownerName
{
    if (self = [super init]) {
        _zoneName = zoneName;
        _ownerName = ownerName ? ownerName : CKOwnerDefaultName;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    return [self initWithZoneName:dictionary[@"zoneName"] ownerName:dictionary[@"ownerName"]];
}

#pragma mark - NSCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_zoneName forKey:@"zoneName"];
    [aCoder encodeObject:_ownerName forKey:@"ownerName"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSString *zoneName = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"zoneName"];
    NSString *ownerName = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"ownerName"];
    return [self initWithZoneName:zoneName ownerName:ownerName];
}

#pragma mark - Equals

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CKRecordZoneID class]]) {
        return [self.zoneName isEqualToString:[(CKRecordZoneID *)object zoneName]] && [self.ownerName isEqual:[(CKRecordZoneID *)object ownerName]];
    }
    return NO;
}

- (NSUInteger)hash
{
    return [self.zoneName hash] ^ [self.ownerName hash];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithZoneName:self.zoneName ownerName:self.ownerName];
}

#pragma mark - Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"[CKRecordZoneID: %@ %@]", self.zoneName, self.ownerName];
}

@end
