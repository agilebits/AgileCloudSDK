# Agile CloudKit
A drop in replacement for CloudKit framework for use in non-Mac App Store apps. Uses CloudKitJS for all communcations.

## Building
```
$ git clone git@github.com:adamwulf/agile-cloud.git
$ cd agile-cloud
$ open AgileCloud.xcworkspace
```
### Compile the framework
Pick the AgileCloudKit to build the framework

### Configuration
1. Pick an App ID and update the sample apps' Info.plist
2. Add a CloudKit container for the new App ID
3. Log in to https://icloud.developer.apple.com/dashboard/
    - Create a new API Key
    - Choose the callback URL that uses the app's ID as the scheme
    - the host of the callback URL should be set to "agilecklogin"
4. Update the API Key in the CKMediator.m, the #define is at the top
5. Update the CloudKitContainerName #define in CKMediator to match the CloudKit container for your app ID
6. Add that same scheme to the sample apps' URL Types in their project settings

### Sample Apps
Two apps are bundled with the framework. The CloudZone app uses Apple's CloudKit framework, and the AgileCloudZone uses the AgileCloudKit framework.

The sample app simply shows a login button if using the AgileCloudKit framework. Once the app starts up, it logs its progress to the console. It will use the convenience API and the block API to add, fetch, and delete zones in the user's private database.

## Goals

 - [x] Compile and link the AgileCloudKit framework to easily replace CloudKit
 - [x] Handle authentication and appropriate callbacks
 - [x] Handle fetching and modifying Zones
 - [ ] Implement saving, fetching, modifying, and deleting CKRecords
 - [ ] Implement saving CKAssets
 - [ ] Implement the rest of the Operations, order TBD
