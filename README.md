![alt text](https://raw.githubusercontent.com/jalingo/MagicCloud/master/Badge.png)

MagicCloud       
==========
[![License](https://img.shields.io/github/license/jalingo/MagicCloud.svg)](http://opensource.org/licenses/BSD-new)
[![CocoaPods Platform](https://img.shields.io/cocoapods/p/MagicCloud.svg)](https://github.com/jalingo/MagicCloud)
[![Language](https://img.shields.io/badge/language-Swift-orange.svg)](https://github.com/jalingo/MagicCloud)
[![CocoaPods Tag](https://img.shields.io/cocoapods/v/MagicCloud.svg)](https://github.com/jalingo/MagicCloud)
[![iOS App Store](https://img.shields.io/badge/App%20Store-Approved-brightgreen.svg)](https://escapechaos/magiccloud)
[![Jazzy Docs](https://img.shields.io/badge/Jazzy%20Docs-100%25-green.svg)](https://github.com/jalingo/MagicCloud)

**Magic Cloud** is a **Swift (iOS) Framework** that makes using **CloudKit** simple and easy.

For any data types that need to be saved as database records, just conform them to the `MCRecordable` protocol. Then the generic `MCMirror` classes can maintain a local array of that type, and mirror it to **CloudKit's** databases in the background.

Default setup covers _error handling, subscriptions, account changes and more_. Can be configured / customized for optimized performance (for more details on that, the **Magic Cloud Blog** is coming to our [site](escapechaos.com)), or just use as is. 

Check out the **Quick Start Guide** and see an app add working cloud functionality with _less than 20 lines of code!_

## Requirements

Meet the requirements for **CloudKit**, which includes a _paid developer account_.

An **iOS** project (min 10.3), that requires a relational database. (Why wouldn't you use Swift for that?)

Does **NOT** directly support shared databases (upcoming version).

## Getting Started

In order to use **Magic Cloud**, a project has to be configured for **CloudKit** and the **MagicCloud** framework will need to be linked to its workspace.

### Preparing App for CloudKit

**Magic Cloud** is meant to work on top of **Apple's CloudKit** technology, not replace it. The developer does not maintain any actual databases and is not responsible for _data integrity, security or loss_.

Before installing **Magic Cloud** be sure **CloudKit** and **Push Notification** are [enabled in your project's capabilities](https://developer.apple.com/library/content/documentation/DataManagement/Conceptual/CloudKitQuickStart/EnablingiCloudandConfiguringCloudKit/EnablingiCloudandConfiguringCloudKit.html).

### Installations

If you're comfortable using **CocoaPods** to [manage your dependencies](https://guides.cocoapods.org/using/getting-started.html) (recommended), add the following in the podfile. 

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.3'   # <- 10.3 minimum requirement, can be more recent...
use_frameworks!         # <- MagicCloud is a swift framework, ensure this is present.

target '<Your Target Name>' do
    pod 'MagicCloud', '~> 3.0.1'  # <- Be sure to use the current version.
end
```

Then, from your project's directory...

```bash
pod install
```

Alternatively, clone from [github](github.com/jalingo/MagicCloud), then add the framework to your project manually (not recommended).

### Quick Start Guide

Check out the **Quick Start Guide**, a how-to video at [Escape Chaos](https://www.escapechaos.com/magiccloud), to see a test app get fully configured in less than 20 lines of code.

## Examples

For basic projects, these examples should be all that is necessary.

### MCNotificationConverter

Once you have **CloudKit** enabled and the cocoapod installed, there's one last piece of configuration that has to happen in the app delegate.

First make your app delegate conform to **MCNotificationConverter**.

```swift
class AppDelegate: UIResponder, UIApplicationDelegate, MCNotificationConverter {    // <-- Add it here...
```

Next, insert the following two lines into the `didFinishLaunchingWithOptions` method already in the app delegate.

```swift
        MCUserRecord.verifyAccountAuthentication()      // <-- More information about this below @ MCUserRecord
        application.registerForRemoteNotifications()
```

Finally, scroll down and insert **ONE of the FIRST TWO methods** into the same class.

```swift
    // This is the current way ...
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        convertToLocal(from: userInfo)
    }
```

```swift
    // This version is deprecated, but works for pre-iOS 10 apps...
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        convertToLocal(from: userInfo)
    }
    
```

```swift
    // This version DOES NOT work for silent push notifications, so it will miss any pushes from Magic Cloud...
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        convertToLocal(from: userInfo)          // <-- DOES NOT WORK !!
    }
```

With that in place, any notifications from the **CloudKit** databases will be converted to a local notification and handled by any `MCMirror`s that are setup. 

If you'll need to disable any of your features during a subscription failure (e.g. airplane mode, bad network connection, etc...), add this method to the app delegate and do so here (or more likely, post a notification here).

```swift
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // This is only one of the ways you can 'gracefully disable' features that require cloud. 
    }
```

With all the setup / configuration out of the way, now you can get started...

### MCRecordable

Any data type that needs to have it's model stored as records (and it's properties saved as those records' fields) will need to conform to the `MCRecordable` protocol. Currently, **Magic Cloud** doesn't handle `CKRecords` directly.

```swift
extension MockType: MCRecordable {
    
    public var recordType: String { return "MockType" }            // <-- This string will serve as a CKRecordType.Name
    
    public var recordFields: Dictionary<String, CKRecordValue> {   // <-- This is where the properties that should be CKRecord   
        get {                                                      //     fields are updated / recovered. 
            return [Mock.key: created as CKRecordValue] 
        }
        
        set {
            if let date = newValue[Mock.key] as? Date { created = date }
        }
    }
    
    public var recordID: CKRecordID {                              // <-- This ID needs to be unique for each instance.
        get { return _recordID ?? CKRecordID(recordName: "EmptyRecord") }
        set { _recordID = newValue }                               // <-- This value needs to be saved when instances are
    }                                                              //     created from downloaded database records. 
    
    // MARK: - Functions: Recordable
    
    public required init() { }                                     // <-- This empty init is used to generate empty instances
}                                                                  //     that can then be overwritten from database records.
```

### MCMirror

Once there are recordables to work with, use `MCMirror`(s) to save and recover these types in the `CloudKit` databases.

```swift
let mocksInPublicDatabase = MCMirror<MockType>(db: .publicDB)
let mocksInPrivateDatabase = MCMirror<MockType>(db: .privateDB)
```

Shortly after they're initialized, the receivers should finish downloading and transforming any existing records. These can be accessed from the `dataModel` array.

```swift
let publicMocks = mocksInPublicDatabase.dataModel
```

Voila! Any changes to records in the cloud database (add / edit / remove) will automatically be reflected in the receiver's recordables array until it deinits. When elements are added, modified or deleted from the `cloudRecordables` array, the `MCMirror` will ensure those changes are mirrored to the respective database in the background.

```swift
let new = MockType(created: Date())

mocksInPublicDatabase.cloudRecordables.append(new)                      // <-- This will add a new record to the database.

mocksInPublicDatabase.cloudRecordables[0].created = Date.distantFuture  // <-- This will modify an existing database record.

mocksInPublicDatabase.cloudRecordables.removeLast                       // <-- This will remove a record from the database.
```

**Note:**  While multiple mirrors for the same data type in the same app reduces stability, it is supported. Any change should be reflected in all mirrors, both in the local app and in other users' apps.

### MCUserRecord

If you're dealing with private databases or need a unique token for each cloud account, use `MCUserRecord` to retrieve the user's unique **iCloud** identifier.

```swift
if let userRecord = MCUserRecord().singleton {          // <-- Returns nil if not logged in OR if not connected to network.
    print("User Record: \(userRecord.recordName)") 
}
```

To test if a user is logged in to their **iCloud** account, and have them receive a warning with a link to the **Settings** app if not, simply call the following static method.

```swift
MCUserRecord.verifyAccountAuthentication()
```

If needed, you'll probably want to get this out of the way in the app delegate (`didFinishLaunchingWithOptions` method is recommended).

## Considerations

While the aforementioned code is all that is needed for most projects, there are still a few design considerations and common issues to keep in mind.

### Concurrency, Grand Central Dispatch & the Main Thread

If this project is your first attempt at working with asynchronous operations, **Apple** has several great resources out there that will ultimately save you a lot of time and trouble...

[CloudKit QuickStart](https://developer.apple.com/library/content/documentation/DataManagement/Conceptual/CloudKitQuickStart/Introduction/Introduction.html)

[CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)

[Concurrency Programming Guide](https://developer.apple.com/library/content/documentation/General/Conceptual/ConcurrencyProgrammingGuide/Introduction/Introduction.html)

[CloudKit Design Guide](https://developer.apple.com/library/content/documentation/General/Conceptual/iCloudDesignGuide/DesigningforCloudKit/DesigningforCloudKit.html#//apple_ref/doc/uid/TP40012094-CH9-SW1)

**Apple** and **Magic Cloud** have done most of the heavy lifting, but you will still have to understand the order your processes will execute and that varying amounts of time will be needed for cloud interactions to occur. **Dispatch Groups** (and **XCTExpectations** for unit testing) can be very helpful, in this regard.

Do ***NOT*** lock up the **main thread** with cloud activity; every app needs to have separate threads for updating views and  waiting for data. If you're not sure what that means, then you may want to review the documentation mentioned above.

### Error Notifications

**Error Handling** is a big part of cloud development, but in most cases **Magic Cloud** can deal with them sufficiently. For developers that need to perform additional handling, every time an issue is encountered a **Notification** is posted that includes the original **CKError**.

To listen for these notifications, use `MCErrorNotification`.

```swift
let name = Notification.Name(MCErrorNotification)
NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { notification in

     // Error notifications from MagicCloud should always include the actual CKError as Notification.object.
     if let error = notification.object as? CKError { print("CKError: \(error.localizedDescription)") }
}
```

**CAUTION:**  In cases where there's a batch issue, a single error may generate multiple notifications.

### CloudKit Dashboard

Each **CloudKit** container can be directly accessed at the [CloudKit Dashboard](https://icloud.developer.apple.com/dashboard), where developers can modify the database schema, query / modify records, manage subscriptions, etc...

**DON'T FORGET** to make all record names queryable. `MCMirror`s use those names to find and fetch records.

## Reporting Bugs

If you've had any issues, first please review the existing documentation thoroughly. After being certain that you're dealing with a replicable bug, the best way to submit the issue is through GitHub.

```
@ github.com/jalingo/MagicCloud > "Issues" tab > "New Issue" button
```

You can also email `dev@escapechaos.com`, or for a more immediate response try **Stack Overflow**.
