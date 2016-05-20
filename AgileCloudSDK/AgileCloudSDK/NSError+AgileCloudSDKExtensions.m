//
//  NSError+AgileCloudSDKExtensions.m
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import "NSError+AgileCloudSDKExtensions.h"
#import "CKError.h"

@implementation NSError (AgileCloudSDKExtensions)

- (instancetype)initWithCKErrorDictionary:(NSDictionary *)ckErrorDictionary
{
    if (ckErrorDictionary[@"serverErrorCode"]) {
        NSMutableDictionary *errorDict = [NSMutableDictionary dictionaryWithDictionary:ckErrorDictionary];
        errorDict[@"_ckErrorCode"] = errorDict[@"serverErrorCode"];
        ckErrorDictionary = errorDict;
    }

    CKErrorCode code = CKErrorInternalError;
    if ([ckErrorDictionary[@"_ckErrorCode"] isEqualToString:@"ACCESS_DENIED"]) {
        code = CKErrorPermissionFailure;
    } else if ([ckErrorDictionary[@"_ckErrorCode"] isEqualToString:@"ATOMIC_ERROR"]) {
        code = CKErrorBatchRequestFailed;
    } else if ([ckErrorDictionary[@"_ckErrorCode"] isEqualToString:@"AUTHENTICATION_FAILED"]) {
        code = CKErrorNotAuthenticated;
    } else if ([ckErrorDictionary[@"_ckErrorCode"] isEqualToString:@"AUTHENTICATION_REQUIRED"]) {
        code = CKErrorNotAuthenticated;
    } else if ([ckErrorDictionary[@"_ckErrorCode"] isEqualToString:@"BAD_REQUEST"]) {
        code = CKErrorUnknownItem;
    } else if ([ckErrorDictionary[@"_ckErrorCode"] isEqualToString:@"CONFLICT"]) {
        code = CKErrorConstraintViolation;
    } else if ([ckErrorDictionary[@"_ckErrorCode"] isEqualToString:@"EXISTS"]) {
        code = CKErrorServerRejectedRequest;
    } else if ([ckErrorDictionary[@"_ckErrorCode"] isEqualToString:@"INTERNAL_ERROR"]) {
        code = CKErrorInternalError;
    } else if ([ckErrorDictionary[@"_ckErrorCode"] isEqualToString:@"NOT_FOUND"]) {
        code = CKErrorUnknownItem;
    } else if ([ckErrorDictionary[@"_ckErrorCode"] isEqualToString:@"QUOTA_EXCEEDED"]) {
        code = CKErrorQuotaExceeded;
    } else if ([ckErrorDictionary[@"_ckErrorCode"] isEqualToString:@"THROTTLED"]) {
        code = CKErrorRequestRateLimited;
    } else if ([ckErrorDictionary[@"_ckErrorCode"] isEqualToString:@"TRY_AGAIN_LATER"]) {
        code = CKErrorZoneBusy;
    } else if ([ckErrorDictionary[@"_ckErrorCode"] isEqualToString:@"VALIDATING_REFERENCE_ERROR"]) {
        code = CKErrorConstraintViolation;
    } else if ([ckErrorDictionary[@"_ckErrorCode"] isEqualToString:@"UNIQUE_FIELD_ERROR"]) {
        code = CKErrorConstraintViolation;
    } else if ([ckErrorDictionary[@"_ckErrorCode"] isEqualToString:@"ZONE_NOT_FOUND"]) {
        code = CKErrorZoneNotFound;
    } else if ([ckErrorDictionary[@"_ckErrorCode"] isEqualToString:@"UNKNOWN_ERROR"]) {
        code = CKErrorInternalError;
    } else if ([ckErrorDictionary[@"_ckErrorCode"] isEqualToString:@"NETWORK_ERROR"]) {
        code = CKErrorNetworkFailure;
    } else if ([ckErrorDictionary[@"_ckErrorCode"] isEqualToString:@"SERVICE_UNAVAILABLE"]) {
        code = CKErrorServiceUnavailable;
    } else if ([ckErrorDictionary[@"_ckErrorCode"] isEqualToString:@"INVALID_ARGUMENTS"]) {
        code = CKErrorInvalidArguments;
    }
    if (self = [self initWithDomain:CKErrorDomain code:code userInfo:ckErrorDictionary]) {
    }
    return self;
}

@end
