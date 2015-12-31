//
//  CKRecordID.m
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgileCloudKit/AgileCloudKit.h>
#import "CKRecordID.h"
#import "Defines.h"

@implementation CKRecordID

- (instancetype)init
{
    @throw kInvalidMethodException;
}

/* Record names must be 255 characters or less. Most UTF-8 characters are valid. */
/* This creates a record ID in the default zone */
- (instancetype)initWithRecordName:(NSString *)recordName
{
    return [self initWithRecordName:recordName zoneID:[[CKRecordZone defaultRecordZone] zoneID]];
}

- (instancetype)initWithRecordName:(NSString *)recordName zoneID:(CKRecordZoneID *)zoneID
{
    if (self = [super init]) {
        _recordName = recordName;
        _zoneID = zoneID;
    }
    return self;
}

#pragma mark - NSCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_recordName forKey:@"recordName"];
    [aCoder encodeObject:_zoneID forKey:@"zoneID"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSString *recordName = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"recordName"];
    CKRecordZoneID *zoneID = [aDecoder decodeObjectOfClass:[CKRecordZoneID class] forKey:@"zoneID"];
    return [self initWithRecordName:recordName zoneID:zoneID];
}

#pragma mark - Equals

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CKRecordID class]]) {
        return [self.recordName isEqualToString:[(CKRecordID *)object recordName]] && [self.zoneID isEqual:[(CKRecordID *)object zoneID]];
    }
    return NO;
}

- (NSUInteger)hash
{
    return [self.recordName hash] ^ [self.zoneID hash];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithRecordName:[self.recordName copyWithZone:zone] zoneID:[self.zoneID copyWithZone:zone]];
}

#pragma mark - Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"[CKRecordID: %@ %@]", self.recordName, self.zoneID];
}

@end
