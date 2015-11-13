//
//  CKRecord_Private.h
//  AgileCloudKit
//
//  Created by Adam Wulf on 9/8/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKRecord.h"

@interface CKRecord (AgilePrivate)

- (instancetype)initWithDictionary:(NSDictionary *)dictionary inZone:(CKRecordZoneID *)zoneID;

- (void)updateWithDictionary:(NSDictionary *)dictionary;

// returns an array of all errors encountered during downloading, if any
- (NSArray *)synchronouslyDownloadAllAssetsWithProgressBlock:(void (^)(double progress))progressBlock;

- (NSArray *)synchronouslyUploadAssetsIntoDatabase:(CKDatabase *)database;

+ (NSObject<CKRecordValue> *)recordValueFromDictionary:(NSDictionary *)dictionary inZone:(CKRecordZoneID *)zoneID;

@end
