//
//  CKServerChangeToken.h
//  CloudKit
//
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <AgileCloudKit/CKDatabaseOperation.h>
#import "CKServerChangeToken.h"
#import "CKServerChangeToken_Private.h"
#import "CKServerChangeToken+AgileDictionary.h"

@implementation CKServerChangeToken {
    NSString *_token;
}

- (instancetype)initWithString:(NSString *)token
{
    if (self = [super init]) {
        _token = token;
    }
    return self;
}

- (NSString *)token
{
    return _token;
}

#pragma mark - NSCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.token forKey:@"token"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSString *token = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"token"];
    if (self = [self initWithString:token]) {
        // noop
    }
    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] initWithString:[_token copyWithZone:zone]];
}

#pragma mark - Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"[CKServerChangeToken: %@]", self.token];
}

@end
