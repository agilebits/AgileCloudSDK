# AgileCloudSDK

AgileCloudSDK is a framework for use in non-Mac App Store apps. It uses CloudKitJS and CloudKit Web Services to communicate with iCloud.

AgileCloudSDK is a proven technology currently in use by [1Password](https://1password.com) when purchased from the AgileBits Store. 1Password uses AgileCloudSDK to sync password data seamlessly with the Mac App Store and iOS App Store versions which use Apple’s native CloudKit framework.

## License

See the [license file](License.txt) for AgileCloudSDK’s distribution license

## Using AgileCloudSDK

See the file named [Using AgileCloudSDK](Using%20AgileCloudSDK.md) for information on how to set up AgileCloudSDK in your application.

## Still to do

### API

AgileCloudSDK does not yet provide full functionality. There are a few classes that are not yet implemented. Of note are:

	- CKFetchSubscriptionsOperation
	- CKDiscoverAllContactsOperation
	- CKDiscoverUserInfosOperation
	- CKFetchWebAuthTokenOperation
	- CKLocationSortDescriptor
	- CKModifyBadgeOperation
	- CKQuery: this doesn’t have a direct equivalent in CloudKit JS. CloudKitJS uses filters: JSON dictionaries with query parameters.  CKQuery uses NSPredicate which works quite differently from JSON query dictionaries. AgileCloudSDK contains the CKFilter class to provide query functionality but due to the different nature of the NSPredicates and CKFilters, making a direct implementation of CKOperations that use the CKQuery class would be difficult.
	- CKQueryOperation
	- CKQueryNotification

Some classes do not implement every method as CloudKit, particularly those methods that have been added in OS X 10.11.

### JavaScript vs REST API

AgileCloudSDK communicates with iCloud using a mix of JavaScript calls from a JavaScript context and the REST API. The long term goal is to move toward using the REST API. This has a number of advantages, one of which is eliminating the need for a Javascript context that runs on the main thread.

## CloudZone Sample Apps

Two apps are bundled with the framework. The CloudZone app uses Apple's CloudKit framework, and the AgileCloudZone uses the AgileCloudSDK framework. The sample apps may not contain all functionality of the framework. They are there to act as a playground to test different aspects of the framework as needed.

To use the CloudZone apps you will need to set up a test container in CloudKit Dashboard, and set the appropriate App IDs and credentials in the two apps. The CloudZone app requires the iCloud CloudKit capabilities enabled and must have Mac App Store code signing set in order to use native CloudKit. The AgileCloudZone app does not need to be signed as it uses CloudKitJS, but does need the appropriate CloudKitJS credentials and the URL type set in its Info.plist. There are placeholder values in the project that can be modified.

The CloudZone apps are minimal and have a few rough edges, but have a few features:

1. Login/Logout - This button appears only in AgileCloudSDK. It's used for well, logging in and out.
2. Start Tests - Runs a suite of eight tests to test the various aspects of the AgileCloudSDK framework.
3. Subscribe - Activates the subscription, so it will receive notifications when data is changed on another device (or from the CloudZone to AgileCloudZone, and vice versa).
4. Save Record - Saves what ever text is in the text field to iCloud. When you first run one of the apps, it loads that record and populates the text field. Likewise, when a change notification comes in, that text field should update to the new value.
