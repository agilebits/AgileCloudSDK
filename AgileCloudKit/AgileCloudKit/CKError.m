//
//  CKError.m
//  AgileCloudKit
//
//  Created by Adam Wulf on 8/22/15.
//  Copyright (c) 2015 Adam Wulf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKError.h"

NSString *const CKErrorDomain = @"CKErrorDomain";

NSString *const CKPartialErrorsByItemIDKey = @"CKPartialErrorsByItemIDKey";

/* If the server rejects a record save because it has been modified since the last time it was read,
 a CKErrorServerRecordChanged error will be returned and it will contain versions of the record
 in its userInfo dictionary. Apply your custom conflict resolution logic to the server record (CKServerRecordKey)
 and attempt a save of that record. */
NSString *const CKRecordChangedErrorAncestorRecordKey = @"CKRecordChangedErrorAncestorRecordKey";
NSString *const CKRecordChangedErrorServerRecordKey = @"CKRecordChangedErrorServerRecordKey";
NSString *const CKRecordChangedErrorClientRecordKey = @"CKRecordChangedErrorClientRecordKey";

/* On CKErrorServiceUnavailable or CKErrorRequestRateLimited errors the userInfo dictionary
 may contain a NSNumber instance that specifies the period of time in seconds after
 which the client may retry the request.
 */
NSString *const CKErrorRetryAfterKey = @"CKErrorRetryAfterKey";
