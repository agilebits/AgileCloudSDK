//
//  CKNotificationInfo.h
//  AgileCloudKit
//
//  Created by Adam Wulf on 9/13/15.
//  Copyright © 2015 AgileBits. All rights reserved.
//

#import <Foundation/Foundation.h>

/* The payload of a push notification delivered in the UIApplication application:didReceiveRemoteNotification: delegate method contains information about the firing subscription.   Use
 +[CKNotification notificationFromRemoteNotificationDictionary:] to parse that payload. */

@interface CKNotificationInfo : NSObject <NSSecureCoding, NSCopying>

/* Optional alert string to display in a push notification. */
@property(nonatomic, copy) NSString *alertBody;

/* Instead of a raw alert string, you may optionally specify a key for a localized string in your app's Localizable.strings file. */
@property(nonatomic, copy) NSString *alertLocalizationKey;

/* A list of field names to take from the matching record that is used as substitution variables in a formatted alert string. */
@property(nonatomic, copy) NSArray /* NSString */ *alertLocalizationArgs;

/* A key for a localized string to be used as the alert action in a modal style notification. */
@property(nonatomic, copy) NSString *alertActionLocalizationKey;

/* The name of an image in your app bundle to be used as the launch image when launching in response to the notification. */
@property(nonatomic, copy) NSString *alertLaunchImage;

/* The name of a sound file in your app bundle to play upon receiving the notification. */
@property(nonatomic, copy) NSString *soundName;

/* A list of keys from the matching record to include in the notification payload.
 Only some keys are allowed.  The value types associated with those keys on the server must be one of these classes:
 CKReference
 CLLocation
 NSDate
 NSNumber
 NSString */
@property(nonatomic, copy) NSArray /* NSString */ *desiredKeys;

/* Indicates that the notification should increment the app's badge count. Default value is NO. */
@property(nonatomic, assign) BOOL shouldBadge;

/* Indicates that the notification should be sent with the "content-available" flag to allow for background downloads in the application.
 Default value is NO. */
@property(nonatomic, assign) BOOL shouldSendContentAvailable;

@end
