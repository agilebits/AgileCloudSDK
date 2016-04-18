//
//  CKRecordZone.m
//  AgileCloudKit
//
//  Copyright (c) 2015 AgileBits Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgileCloudKit/AgileCloudKit.h>
#import "CKRecordZone.h"


@implementation CKRecordZone

+ (CKRecordZone *)defaultRecordZone {
    return [[CKRecordZone alloc] initWithZoneName:@"_defaultZone"];
}

- (CKRecordZoneCapabilities)capabilities {
    return CKRecordZoneCapabilityAtomic | CKRecordZoneCapabilityFetchChanges;
}

- (instancetype)initWithZoneName:(NSString *)zoneName {
    return [self initWithZoneID:[[CKRecordZoneID alloc] initWithZoneName:zoneName]];
}

- (instancetype)initWithZoneID:(CKRecordZoneID *)zoneID {
    if (self = [super init]) {
        _zoneID = zoneID;
    }
    return self;
}

#pragma mark - NSCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_zoneID forKey:@"zoneID"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    CKRecordZoneID *zoneID = [aDecoder decodeObjectOfClass:[CKRecordZoneID class] forKey:@"zoneID"];
    return [self initWithZoneID:zoneID];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithZoneID:[self.zoneID copyWithZone:zone]];
}

@end
