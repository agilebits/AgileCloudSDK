## Using AgileCloudKit

#### Compile or include the framework

Choose the AgileCloudKit to build the framework, or include the AgileCloudKit project in your project.

#### Prepare your container on CloudKit Dashboard

Log in to CloudKitDashboard with your Developer AppleID: https://icloud.developer.apple.com/Dashboard

1. Go to your Development container
1. Create a new API key
1. Set the sign-in callback URL to launch your app with `cloudkit-containerID` as the scheme and `agilecklogin` as the host. For example, `cloudkit-icloud.com.company.appname://agilecklogin` 
1. Repeat for your Production container

#### Configure your application’s Info.plist file

1. Add a Dictionary to the array with the following key-value pairs:
1. Create an Array named `CloudKitJSContainers`
	- `CloudKitJSAPIToken`:`<token>` This is the API token created in CloudKitDashboard
	- `CloudKitJSEnvironment`:`production` or `development`
	- `CloudKitJSContainerName`:your app's CloudKit container id. e.g. `iCloud.com.company.app`

#### Add code to your classes

1. Stand up the CKMediator. CKMediator is the class that mediates native cloudkit calls to CloudKit JS. It must be instantiated and set up first.

	- the following code sets up the mediator and registers for notification types so your app receives cloudkit notifications.
		```
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			[CKMediator sharedMediator].delegate = (id<CKMediatorDelegate>)NSApp.delegate;
			[NSApp registerForRemoteNotificationTypes:0xFFFF];
		});
		```
		
1. Implement the CKMediatorDelegate methods. These are defined in CKMediatorDelegate.h
	- you must implement the methods to load and save the login token, and it is recommended the token be stored securely. This allows your application to continue to communicate with CloudKit without needing to prompt the user to login each time. It can expire, for example, when the user changes their AppleID password, or for other reasons.
	- the optional logging method allows your app to receive logging messages from AgileCloudKit with varying levels of severity. Those levels are defined in CKMediatorDelegate.h
	
1. Handle the sign-in URL callback.

	- Register an event handle with the AppleEventManager to receive URLs if you are not already. For example,
		```
		[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleURLSchemeEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
		```
	- In your handleURLSchemeEvent method, hand the cloudkit URL off to the shared mediator
		```
		[[CKMediator sharedMediator] handleGetURLEvent:event withReplyEvent:replyEvent];
		```

1. Import the framework with the standard header: `#import <AgileCloudKit/AgileCloutKit.h>`

1. Logging in, logging out, and handling Authorization Errors

	- CloudKit operations will call completion blocks with a CKError object with code `CKErrorNotAuthenticated` when the token is missing or invalid. You must call `[CKMediator sharedMediator] login]` when this happens. This will open a browser page displaying your App's name and icon, and prompt the user to log in to iCloud. Your app will receive a callback URL (the one you registered on CloudKit Dashboard) after the user successfully logs in via a web page and call the CKMediatorDelegate's saveToken method.
	- To invalidate your token and log out of CloudKit, call `[CKMediator sharedMediator] logout]`;

