//
//  CKReference.h
//  CloudKit
//
//  Copyright (c) 2015 AgileBits Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgileCloudKit/AgileCloudKit.h>
#import "CKReference.h"
#import "Defines.h"

@implementation CKReference

- (instancetype)init
{
    @throw kInvalidMethodException;
}

- (instancetype)initWithRecord:(CKRecord *)record action:(CKReferenceAction)action
{
    return [self initWithRecordID:record.recordID action:action];
}

/* It is acceptable to relate two records that have not yet been uploaded to the server, but those records must be uploaded to the server in the same operation.
 If a record references a record that does not exist on the server and is not in the current save operation it will result in an error. */
- (instancetype)initWithRecordID:(CKRecordID *)recordID action:(CKReferenceAction)action
{
    if (self = [super init]) {
        _recordID = recordID;
        _referenceAction = action;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary inZone:(CKRecordZoneID *)zoneID
{
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:dictionary[@"recordName"] zoneID:zoneID];
    CKReferenceAction action = [dictionary[@"action"] isEqualToString:@"NONE"] ? CKReferenceActionNone : CKReferenceActionDeleteSelf;
    return [self initWithRecordID:recordID action:action];
}

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:dictionary[@"recordName"] zoneID:_recordID.zoneID];
    CKReferenceAction action = [dictionary[@"action"] isEqualToString:@"NONE"] ? CKReferenceActionNone : CKReferenceActionDeleteSelf;

    _recordID = recordID;
    _referenceAction = action;
}


#pragma mark - NSCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_recordID forKey:@"recordID"];
    [aCoder encodeObject:@(_referenceAction) forKey:@"referenceAction"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    CKRecordID *recordID = [aDecoder decodeObjectOfClass:[CKRecordID class] forKey:@"recordID"];
    CKReferenceAction action = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:@"referenceAction"] unsignedIntegerValue];
    if (self = [self initWithRecordID:recordID action:action]) {
        // noop
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithRecordID:[_recordID copyWithZone:zone] action:_referenceAction];
}

#pragma mark - Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"[CKReference: %lu %@]", self.referenceAction, self.recordID];
}

@end
