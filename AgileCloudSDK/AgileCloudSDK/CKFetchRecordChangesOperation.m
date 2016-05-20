//
//  CKFetchRecordChangesOperation.m
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits Inc. All rights reserved.
//

#import "CKFetchRecordChangesOperation.h"
#import "CKDatabaseOperation_Private.h"
#import "NSError+AgileCloudSDKExtensions.h"
#import "NSArray+AgileMap.h"
#import "CKRecordID+AgileDictionary.h"
#import "CKServerChangeToken+AgileDictionary.h"
#import "CKDatabase_Private.h"
#import "CKServerChangeToken_Private.h"
#import "CKRecord_Private.h"
#import "Defines.h"
#import "CKRecordZoneID.h"

@implementation CKFetchRecordChangesOperation

/* This operation will fetch all records changes in the given record zone.
 If a change anchor from a previous CKFetchRecordChangesOperation is passed in, only the records that have changed
 since that anchor will be fetched.
 If this is your first fetch or if you wish to re-fetch all records, pass nil for the change anchor.
 Change anchors are opaque tokens and clients should not infer any behavior based on their content. */
- (instancetype)initWithRecordZoneID:(CKRecordZoneID *)recordZoneID previousServerChangeToken:(CKServerChangeToken *)previousServerChangeToken {
	if (self = [super init]) {
		_recordZoneID = recordZoneID;
		_previousServerChangeToken = previousServerChangeToken;
	}
	return self;
}


- (void)start {
	[self setExecuting:YES];
	
	NSMutableDictionary *requestDictionary = [NSMutableDictionary dictionaryWithDictionary:@{
																							 @"zoneID": @{@"zoneName": _recordZoneID.zoneName}
																							 }];
	if (_desiredKeys) {
		requestDictionary[@"desiredKeys"] = _desiredKeys;
	}
	if (_resultsLimit) {
		requestDictionary[@"resultsLimit"] = @(_resultsLimit);
	}
	if (_previousServerChangeToken) {
		requestDictionary[@"syncToken"] = [_previousServerChangeToken asString];
	}
	
	[self.database sendPOSTRequestTo:@"records/changes" withJSON:requestDictionary completionHandler:^(id jsonResponse, NSError *operationError) {
		
		__block NSError* localOperationError;
		
		_moreComing = [jsonResponse[@"moreComing"] boolValue];
		CKServerChangeToken *serverChangeToken = [[CKServerChangeToken alloc] initWithString:jsonResponse[@"syncToken"]];
		
		if ([jsonResponse isKindOfClass:[NSDictionary class]] && jsonResponse[@"records"]) {
			[jsonResponse[@"records"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
				NSError* recordError = nil;
				
				if ([obj[@"deleted"] boolValue]) {
					CKRecordID* deletedRecordID = [[CKRecordID alloc] initWithRecordName:obj[@"recordName"] zoneID:_recordZoneID];
					if (self.recordWithIDWasDeletedBlock) {
						self.recordWithIDWasDeletedBlock(deletedRecordID);
					}
				}
				else {
					CKRecord* record = [[CKRecord alloc] initWithDictionary:obj inZone:_recordZoneID];
					CKRecordID* recordID = record.recordID;
					if (!record) {
						recordError = [[NSError alloc] initWithCKErrorDictionary:obj];
						if (obj[@"recordName"]) {
							recordID = [[CKRecordID alloc] initWithRecordName:obj[@"recordName"]  zoneID:_recordZoneID];
						}
					}
					else {
						NSArray* errs = [record synchronouslyDownloadAllAssetsWithProgressBlock:nil];
						if ([errs count]) {
							recordError = errs[0];
							record = nil;
						}
					}
					
					if (record) {
						if (self.recordChangedBlock) {
							self.recordChangedBlock(record);
						}
					}
					else if (!localOperationError) {
						localOperationError = recordError;
					}
				}
			}];
		}
		else if (!operationError) {
			operationError = [[NSError alloc] initWithCKErrorDictionary:jsonResponse];
		}
		if (localOperationError) {
			operationError = localOperationError;
		}
		
		if (self.fetchRecordChangesCompletionBlock) {
			self.fetchRecordChangesCompletionBlock(serverChangeToken, nil, operationError);
		}
		
		
		[self setExecuting:NO];
		[self setFinished:YES];
	}];
}

@end
