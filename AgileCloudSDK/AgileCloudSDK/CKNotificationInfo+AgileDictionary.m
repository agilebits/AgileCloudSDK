//
//  CKNotificationInfo+AgileDictionary.m
//  AgileCloudSDK
//
//  Copyright (c) 2015 AgileBits. All rights reserved.
//

#import "CKNotificationInfo+AgileDictionary.h"

@implementation CKNotificationInfo (AgileDictionary)

- (NSDictionary *)asAgileDictionary {
	NSMutableDictionary *infoDictionary = [NSMutableDictionary dictionary];
	if (self.alertBody) {
		[infoDictionary setObject:self.alertBody forKey:@"alertBody"];
	}
	if (self.alertLocalizationKey) {
		[infoDictionary setObject:self.alertLocalizationKey forKey:@"alertLocalizationKey"];
	}
	if (self.alertLocalizationArgs) {
		[infoDictionary setObject:self.alertLocalizationArgs forKey:@"alertLocalizationArgs"];
	}
	if (self.alertActionLocalizationKey) {
		[infoDictionary setObject:self.alertActionLocalizationKey forKey:@"alertalertActionLocalizationKeyBody"];
	}
	if (self.alertLaunchImage) {
		[infoDictionary setObject:self.alertLaunchImage forKey:@"alertLaunchImage"];
	}
	if (self.soundName) {
		[infoDictionary setObject:self.soundName forKey:@"soundName"];
	}
	[infoDictionary setObject:@(self.shouldBadge) forKey:@"shouldBadge"];
	[infoDictionary setObject:@(self.shouldSendContentAvailable) forKey:@"shouldSendContentAvailable"];
	
	return infoDictionary;
}

@end
