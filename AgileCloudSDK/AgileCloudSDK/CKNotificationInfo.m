//
//  CKNotificationInfo.m
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import "CKNotificationInfo.h"
#import "CKNotificationInfo_Private.h"
#import "CKNotificationInfo+AgileDictionary.h"

@implementation CKNotificationInfo

- (instancetype)init {
	if (self = [super init]) {
	}
	return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
	if (self = [super init]) {
		self.alertBody = [dictionary objectForKey:@"alertBody"];
		self.alertLocalizationKey = [dictionary objectForKey:@"alertLocalizationKey"];
		self.alertLocalizationArgs = [dictionary objectForKey:@"alertLocalizationArgs"];
		self.alertActionLocalizationKey = [dictionary objectForKey:@"alertActionLocalizationKey"];
		self.alertLaunchImage = [dictionary objectForKey:@"alertLaunchImage"];
		self.soundName = [dictionary objectForKey:@"soundName"];
		self.shouldBadge = [[dictionary objectForKey:@"shouldBadge"] boolValue];
		self.shouldSendContentAvailable = [[dictionary objectForKey:@"shouldSendContentAvailable"] boolValue];
	}
	return self;
}


#pragma mark - NSCoding

+ (BOOL)supportsSecureCoding {
	return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	if (self.alertBody) {
		[aCoder encodeObject:self.alertBody forKey:@"alertBody"];
	}
	if (self.alertLocalizationKey) {
		[aCoder encodeObject:self.alertLocalizationKey forKey:@"alertLocalizationKey"];
	}
	if (self.alertLocalizationArgs) {
		[aCoder encodeObject:self.alertLocalizationArgs forKey:@"alertLocalizationArgs"];
	}
	if (self.alertActionLocalizationKey) {
		[aCoder encodeObject:self.alertActionLocalizationKey forKey:@"alertalertActionLocalizationKeyBody"];
	}
	if (self.alertLaunchImage) {
		[aCoder encodeObject:self.alertLaunchImage forKey:@"alertLaunchImage"];
	}
	if (self.soundName) {
		[aCoder encodeObject:self.soundName forKey:@"soundName"];
	}
	[aCoder encodeBool:self.shouldBadge forKey:@"shouldBadge"];
	[aCoder encodeBool:self.shouldSendContentAvailable forKey:@"shouldSendContentAvailable"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super init]) {
		self.alertBody = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"alertBody"];
		self.alertLocalizationKey = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"alertLocalizationKey"];
		self.alertLocalizationArgs = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"alertLocalizationArgs"];
		self.alertActionLocalizationKey = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"alertActionLocalizationKey"];
		self.alertLaunchImage = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"alertLaunchImage"];
		self.soundName = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"soundName"];
		self.shouldBadge = [aDecoder decodeBoolForKey:@"shouldBadge"];
		self.shouldSendContentAvailable = [aDecoder decodeBoolForKey:@"shouldSendContentAvailable"];
	}
	return self;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
	return [[CKNotificationInfo allocWithZone:zone] initWithDictionary:[self asAgileDictionary]];
}

@end
