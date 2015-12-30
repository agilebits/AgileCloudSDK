//
//  CKRecord.h
//  CloudKit
//
//  Copyright (c) 2014 AgileBits Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CLLocation.h>
#import <AgileCloudKit/AgileCloudKit.h>
#import "CKRecord.h"
#import "CKContainer_Private.h"
#import "CKRecord_Private.h"
#import "CKDatabase_Private.h"
#import "CKReference_Private.h"
#import "CKRecordZoneID+AgileDictionary.h"
#import "CKAsset_Private.h"
#import "Defines.h"

@implementation CKRecord {
    NSMutableDictionary *_userDefinedProperties;
    NSMutableArray *_changedKeys;
}

- (instancetype)initWithRecordType:(NSString *)recordType
{
    return [self initWithRecordType:recordType recordID:[[CKRecordID alloc] initWithRecordName:[[NSUUID UUID] UUIDString]]];
}

- (instancetype)initWithRecordType:(NSString *)recordType zoneID:(CKRecordZoneID *)zoneID
{
    return [self initWithRecordType:recordType recordID:[[CKRecordID alloc] initWithRecordName:[[NSUUID UUID] UUIDString] zoneID:zoneID]];
}

- (instancetype)initWithRecordType:(NSString *)recordType recordID:(CKRecordID *)recordID
{
    if (!recordType || !recordID) {
        return nil;
    }
    if (self = [super init]) {
        _recordType = recordType;
        _recordID = recordID;
        _userDefinedProperties = [NSMutableDictionary dictionary];
        _changedKeys = [NSMutableArray array];
    }
    return self;
}

+ (NSObject<CKRecordValue> *)recordValueFromDictionary:(NSDictionary *)dictionary inZone:(CKRecordZoneID *)zoneID
{
    NSString *type = dictionary[@"type"];
    NSObject<CKRecordValue> *val = dictionary[@"value"];
    if ([type isEqualToString:@"STRING"] ||
        [type isEqualToString:@"STRING_LIST"] ||
        [type isEqualToString:@"DOUBLE"] ||
        [type isEqualToString:@"DOUBLE_LIST"]) {
        return val;
    } else if ([type isEqualToString:@"INT64"]) {
        return [NSNumber numberWithInteger:[(NSNumber *)val integerValue]];
    } else if ([type isEqualToString:@"INT64_LIST"]) {
        NSMutableArray *nums = [NSMutableArray array];
        [(NSArray *)val enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [nums addObject:[NSNumber numberWithInteger:[(NSNumber*)obj integerValue]]];
        }];
        return nums;
    } else if ([type isEqualToString:@"BYTES"]) {
        return [[NSData alloc] initWithBase64EncodedString:(NSString *)val options:0];
    } else if ([type isEqualToString:@"BYTES_LIST"]) {
        NSMutableArray *bytelist = [NSMutableArray array];
        [(NSArray *)val enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [bytelist addObject:[[NSData alloc] initWithBase64EncodedString:(NSString*)obj options:0]];
        }];
        return bytelist;
    } else if ([type isEqualToString:@"ASSETID"]) {
        return [[CKAsset alloc] initWithDictionary:(NSDictionary *)val];
    } else if ([type isEqualToString:@"ASSETID_LIST"]) {
        NSMutableArray *assets = [NSMutableArray array];
        [(NSArray *)val enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [assets addObject:[[CKAsset alloc] initWithDictionary:(NSDictionary *)obj]];
        }];
        return assets;
    } else if ([type isEqualToString:@"TIMESTAMP"]) {
        return [[NSDate alloc] initWithTimeIntervalSince1970:[(NSNumber *)val doubleValue] / 1000];
    } else if ([type isEqualToString:@"TIMESTAMP_LIST"]) {
        NSMutableArray *dates = [NSMutableArray array];
        [(NSArray *)val enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            NSDate* dt = [[NSDate alloc] initWithTimeIntervalSince1970:[(NSNumber*)obj doubleValue] / 1000];
            [dates addObject:dt];
        }];
        return dates;
    } else if ([type isEqualToString:@"LOCATION"]) {
        CLLocationDegrees lat = [((NSDictionary *)val)[@"latitude"] doubleValue];
        CLLocationDegrees lon = [((NSDictionary *)val)[@"longitude"] doubleValue];
        return [[CLLocation alloc] initWithLatitude:lat longitude:lon];
    } else if ([type isEqualToString:@"LOCATION_LIST"]) {
        NSMutableArray *locs = [NSMutableArray array];
        [(NSArray *)val enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            CLLocationDegrees lat = [((NSDictionary*)obj)[@"latitude"] doubleValue];
            CLLocationDegrees lon = [((NSDictionary*)obj)[@"longitude"] doubleValue];
            [locs addObject:[[CLLocation alloc] initWithLatitude:lat longitude:lon]];
        }];
        return locs;
    } else if ([type isEqualToString:@"REFERENCE"]) {
        return [[CKReference alloc] initWithDictionary:(NSDictionary *)val inZone:zoneID];
    } else if ([type isEqualToString:@"REFERENCE_LIST"]) {
        NSMutableArray *refs = [NSMutableArray array];
        [(NSArray *)val enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            [refs addObject:[[CKReference alloc] initWithDictionary:obj inZone:zoneID]];
        }];
        return refs;
    } else {
        @throw [NSException exceptionWithName:CKErrorDomain reason:[NSString stringWithFormat:@"Unknown field type: %@", type] userInfo:dictionary];
    }
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary inZone:(CKRecordZoneID *)zoneID
{
    NSString *recordType = dictionary[@"recordType"];
    NSString *recordName = dictionary[@"recordName"];
    if (self = [self initWithRecordType:recordType recordID:[[CKRecordID alloc] initWithRecordName:recordName zoneID:zoneID]]) {
        _recordChangeTag = dictionary[@"recordChangeTag"];
        for (NSString *key in dictionary[@"fields"]) {
            [self setObject:[CKRecord recordValueFromDictionary:dictionary[@"fields"][key] inZone:zoneID] forKey:key];
        }
    }
    if (dictionary[@"created"]) {
        _creationDate = [[NSDate alloc] initWithTimeIntervalSince1970:[dictionary[@"created"][@"timestamp"] doubleValue] / 1000.0];
        _creatorUserRecordID = [[CKRecordID alloc] initWithRecordName:dictionary[@"created"][@"userRecordName"] zoneID:self.recordID.zoneID];
    }
    if (dictionary[@"modified"]) {
        _modificationDate = [[NSDate alloc] initWithTimeIntervalSince1970:[dictionary[@"modified"][@"timestamp"] doubleValue] / 1000.0];
        _lastModifiedUserRecordID = [[CKRecordID alloc] initWithRecordName:dictionary[@"modified"][@"userRecordName"] zoneID:self.recordID.zoneID];
    }

    return self;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary
{
    _recordChangeTag = dictionary[@"recordChangeTag"];
    [_changedKeys removeAllObjects];

    if (dictionary[@"modified"]) {
        _modificationDate = [[NSDate alloc] initWithTimeIntervalSince1970:[dictionary[@"modified"][@"timestamp"] doubleValue] / 1000.0];
        _lastModifiedUserRecordID = [[CKRecordID alloc] initWithRecordName:dictionary[@"modified"][@"userRecordName"] zoneID:self.recordID.zoneID];
    }
    if (dictionary[@"created"]) {
        _creationDate = [[NSDate alloc] initWithTimeIntervalSince1970:[dictionary[@"created"][@"timestamp"] doubleValue] / 1000.0];
        _creatorUserRecordID = [[CKRecordID alloc] initWithRecordName:dictionary[@"created"][@"userRecordName"] zoneID:self.recordID.zoneID];
    }
}


#pragma mark - CKAssets

- (NSArray *)synchronouslyDownloadAllAssetsWithProgressBlock:(void (^)(double progress))progressBlock
{
    NSMutableArray *errors = [NSMutableArray array];
    NSMutableArray *assets = [NSMutableArray array];
    for (NSString *key in [self allKeys]) {
        NSObject<CKRecordValue> *val = self[key];
        if ([val isKindOfClass:[CKAsset class]]) {
            [assets addObject:val];
        }
    }

    for (NSInteger i = 0; i < [assets count]; i++) {
        CKAsset *asset = assets[i];
        [asset downloadSynchronouslyWithProgressBlock:^(double progress) {
            if(progressBlock) progressBlock((i + progress) / (double)[assets count]);
        }];
        if ([asset downloadError]) {
            [errors addObject:[asset downloadError]];
        }
    }

    return errors;
}

- (NSArray *)synchronouslyUploadAssetsIntoDatabase:(CKDatabase *)database
{
    NSMutableArray *assetsToUpload = [NSMutableArray array];
    NSMutableArray *fieldsForAssetUpload = [NSMutableArray array];
    NSMutableArray *errors = [NSMutableArray array];
    for (NSString *key in [self allKeys]) {
        NSObject<CKRecordValue> *val = [self objectForKey:key];
        if ([val isKindOfClass:[CKAsset class]]) {
            CKAsset *asset = (CKAsset *)val;
            if (!asset.wrappingKey) {
                [assetsToUpload addObject:asset];
                [fieldsForAssetUpload addObject:@{ @"recordName": self.recordID.recordName,
                                                   @"recordType": self.recordType,
                                                   @"fieldName": key }];
            }
        } else if ([val isKindOfClass:[NSArray class]] && [[(NSArray *)val firstObject] isKindOfClass:[CKAsset class]]) {
            for (CKAsset *asset in(NSArray *)val) {
                if (!asset.wrappingKey) {
                    [assetsToUpload addObject:asset];
                    [fieldsForAssetUpload addObject:@{ @"recordName": self.recordID.recordName,
                                                       @"recordType": self.recordType,
                                                       @"fieldName": key }];
                }
            }
        }
    }

    if ([fieldsForAssetUpload count]) {
        NSDictionary *requestDictionary = @{ @"zoneID": [self.recordID.zoneID asAgileDictionary],
                                             @"tokens": fieldsForAssetUpload };

        dispatch_semaphore_t downloadSema = dispatch_semaphore_create(0);
        [database sendPOSTRequestTo:@"assets/upload" withJSON:requestDictionary completionHandler:^(id jsonResponse, NSError *error) {
            if(error){
                [errors addObject:error];
            }else{
                for(NSDictionary* uploadInfo in jsonResponse[@"tokens"]){
                    for(int i=0;i<[fieldsForAssetUpload count];i++){
                        NSDictionary* assetInfo = fieldsForAssetUpload[i];
                        if([assetInfo[@"fieldName"] isEqualToString:uploadInfo[@"fieldName"]]){
                            CKAsset* assetToUpload = assetsToUpload[i];

                            NSString* uploadURL = uploadInfo[@"url"];
                            uploadURL = [uploadURL stringByReplacingOccurrencesOfString:@":443" withString:@""];
                            NSURL* urlForUpload = [NSURL URLWithString:uploadURL];
                            dispatch_semaphore_t uploadSema = dispatch_semaphore_create(0);
                            [CKContainer sendPOSTRequestTo:urlForUpload withFile:assetToUpload.fileURL completionHandler:^(id jsonResponse, NSError *error) {
                                if(!error){
                                    [assetToUpload updateWithDictionary:jsonResponse[@"singleFile"]];
                                }else{
                                    [errors addObject:error];
                                }
                                dispatch_semaphore_signal(uploadSema);
                            }];
                            dispatch_semaphore_wait(uploadSema, DISPATCH_TIME_FOREVER);

                            [assetsToUpload removeObjectAtIndex:i];
                            [fieldsForAssetUpload removeObjectAtIndex:i];
                            break;
                        }
                    }
                }
            }
            dispatch_semaphore_signal(downloadSema);
        }];
        dispatch_semaphore_wait(downloadSema, DISPATCH_TIME_FOREVER);
    }

    return errors;
}


#pragma mark - CKRecord

- (id)objectForKey:(NSString *)key
{
    return [_userDefinedProperties objectForKey:key];
}
- (void)setObject:(id<CKRecordValue>)object forKey:(NSString *)key
{
    [_changedKeys addObject:key];
    [_userDefinedProperties setObject:object forKey:key];
}


- (NSArray /* NSString */ *)allKeys
{
    return [_userDefinedProperties allKeys];
}

/* A special property that returns an array of token generated from all the string field values in the record.
 These tokens have been normalized for the current locale, so they are suitable for performing full-text searches. */
- (NSArray /* NSString */ *)allTokens
{
    @throw kAbstractMethodException;
}

- (id)objectForKeyedSubscript:(NSString *)key
{
    return [_userDefinedProperties objectForKeyedSubscript:key];
}

- (void)setObject:(id<CKRecordValue>)object forKeyedSubscript:(NSString *)key
{
    [_changedKeys addObject:key];
    [_userDefinedProperties setObject:object forKeyedSubscript:key];
}

/* A list of keys that have been modified on the local CKRecord instance */
- (NSArray /* NSString */ *)changedKeys
{
    return [_changedKeys copy];
}

/* CKRecord supports NSSecureCoding.  When you invoke
 -encodeWithCoder: on a CKRecord, it encodes all its values.  Including the record values you've set.
 If you want to store a CKRecord instance locally, AND you're already storing the record values locally,
 that's overkill.  In that case, you can use
 -encodeSystemFieldsWithCoder:.  This will encode all parts of a CKRecord except the record keys / values you
 have access to via the -changedKeys and -objectForKey: methods.
 If you use initWithCoder: to reconstitute a CKRecord you encoded via encodeSystemFieldsWithCoder:, then be aware that
 - any record values you had set on the original instance, but had not saved, will be lost
 - the reconstituted CKRecord's changedKeys will be empty
 */
- (void)encodeSystemFieldsWithCoder:(NSCoder *)coder
{
    @throw kAbstractMethodException;
}

#pragma mark - NSCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_recordType forKey:@"recordType"];
    [aCoder encodeObject:_recordID forKey:@"recordID"];
    [aCoder encodeObject:_userDefinedProperties forKey:@"userDefinedProperties"];
	
	[aCoder encodeObject:_creationDate forKey:@"creationDate"];
	[aCoder encodeObject:_modificationDate forKey:@"modificationDate"];
	[aCoder encodeObject:_recordChangeTag forKey:@"recordChangeTag"];
	[aCoder encodeObject:_creatorUserRecordID forKey:@"creatorUserRecordID"];
	[aCoder encodeObject:_lastModifiedUserRecordID forKey:@"lastModifiedUserRecordID"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSString *recordType = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"recordType"];
    CKRecordID *recordID = [aDecoder decodeObjectOfClass:[CKRecordID class] forKey:@"recordID"];
    if (self = [self initWithRecordType:recordType recordID:recordID]) {
        NSDictionary *values = [aDecoder decodeObjectOfClass:[NSDictionary class] forKey:@"userDefinedProperties"];
        _userDefinedProperties = [NSMutableDictionary dictionaryWithDictionary:values];
		_creationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"creationDate"];
		_modificationDate = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"modificationDate"];
		_recordChangeTag = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"recordChangeTag"];
		_creatorUserRecordID = [aDecoder decodeObjectOfClass:[CKRecordID class] forKey:@"creatorUserRecordID"];
		_lastModifiedUserRecordID = [aDecoder decodeObjectOfClass:[CKRecordID class] forKey:@"lastModifiedUserRecordID"];
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithRecordType:[self.recordType copyWithZone:zone] recordID:[self.recordID copyWithZone:zone]];
}

#pragma mark - Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"[CKRecord: %@]", self.recordID];
}

@end

@implementation NSString (CKRecordValue)

@end

@implementation NSNumber (CKRecordValue)
@end

@implementation NSArray (CKRecordValue)
@end

@implementation NSDate (CKRecordValue)
@end

@implementation NSData (CKRecordValue)
@end

@implementation CKReference (CKRecordValue)
@end

@implementation CKAsset (CKRecordValue)
@end

@implementation CLLocation (CKRecordValue)
@end
