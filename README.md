# AgileCloudKit

AgileCloudKit is a drop-in replacement for CloudKit framework for use in non-Mac App Store apps. It uses CloudKitJS and CloudKit Web Services for all communications.

## License

MIT?

## Using AgileCloudKit

See the file named [Using AgileCloudKit](Using%20AgileCloudKit.md) for information on how to set up AgileCloudKit in your application.

## Still to do

### API

AgileCloudKit is not yet a 100% complete implementation of CloudKit. There are a few classes that are not yet implemented. Of note are:
	- CKFetchSubscriptionsOperation
	- CKDiscoverAllContactsOperation
	- CKDiscoverUserInfosOperation
	- CKFetchWebAuthTokenOperation
	- CKLocationSortDescriptor
	- CKModifyBadgeOperation
	- CKQuery - this doesn't have a direct equivalent in CloudKit JS. CloudKitJS uses filters: JSON dictionaries with query parameters.  CKQuery uses NSPredicate which works quite differently from JSON query dictionaries. AgileCloudKit contains the CKFilter class to provide query functionality but due to the different nature of the NSPredicates and CKFilters, making a direct implementation of CKOperations that use the CKQuery class would be difficult.
	- CKQueryOperation
	- CKQueryNotification
	
Some classes do not contain every method as their native CloudKit counterparts, especially those methods that have been added in OS X 10.11.

### JavaScript vs REST API

AgileCloudKit communicates with iCloud using a mix of JavaScript calls from a JavaScript context and the REST API. The long term goal is to move toward using the REST API. This has a number of advantages, one of which is eliminating the need for a Javascript context that runs on the main thread.

## Sample Apps

Two apps are bundled with the framework. The CloudZone app uses Apple's CloudKit framework, and the AgileCloudZone uses the AgileCloudKit framework.

The sample app simply shows a login button if using the AgileCloudKit framework. Once the app starts up, it logs its progress to the console. It will use the convenience API and the block API to add, fetch, and delete zones in the user's private database.
