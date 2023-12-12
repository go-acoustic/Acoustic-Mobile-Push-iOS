# Application Targets
The sample application contains two sets of targets with similar names. The ones prefixed with "Manual" are examples of various manual integration methods. The targets without a prefix are examples of our automatic integration method. 

## Target Base Names
1. **Sample** - iOS Sample Application - Examples of how to use the Mobile Push SDK
2. **Notificaiton Service** - iOS Notification Service Extension - Adds multiple action support and media attachments
3. **Carousel** - Notification Content Extension - Example of how to present a custom View Controller when a notification is expanded and your application is not running 
4. **Watch** - Container for watchOS Extension
5. **Watch Extension** - Examples of how to use the Mobile Push SDK on the Apple Watch

# iOS Application Target
There are two main paths to integrate the Mobile Push SDK with your iOS application. Both require the `AcousticMobilePush.xcframework` to be included in the `Frameworks, Libraries, and Embedded Content` of the target with the  `Embed and sign` option selected. 

## Automatic Integration Flow
Our automatic integration method is designed to simplifiy the integration of the Mobile Push SDK into your application. This is acomplished via overriding the Application Delegate of your application with one that is bundled in our SDK. Your original Application Delegate, specified in the MceConfig.json file, is then instantiated and all Application Delegate calls are forwarded to it. 

This is done by adding a main.swift file and removing the `@UIApplicationMain` flag from your Application Delegate class. Then add a `MceConfig.json` file containing the dev and prod  `appKey`, `baseUrl` and `appDelegateClass` at a minimum. An example of this file is contained in the app with all it's possible options. Note, the MceConfig.json file must be made available to all targets of the application including the Notification Service Extension and Watch Extension. This can be done by simply adding it to those targets. The automatic integration flow does not support providing the configuration in any other way.

In the `application(_:didFinishLaunchingWithOptions:)` method, of your Application Delegate, your code should also register with APNS for remote notifications with `UIApplication.registerForRemoteNotifications()`. It does not prompt the user for permission, but does allow the Mobile Push registration to complete.  

You can ask for authorization from the user to present notifications at this time as well, however this will prompt the user for permissions. We recommend waiting to do this until the user has reached a point in your application that they will need notifications for that feature. Otherwise a user may reject the request out of hand, not knowing the benefits that you provide with push messges. This is done with the `UNUserNotificationCenter.requestAuthorization(options:completionHandler:)` method. Note, even without notification permission, the user is not inaccessible, silent pushes, inbox pushes and inapp pushes can still be used in this state.  

At this point in your code, you can also register to handle actions. Registering your code to execute when actions execute is the best way to respond to actions by the user in push messages, inbox messages and inapp messages. This is done by calling the `MCEActionRegistry.shared.registerTarget(,with:,forAction:)` method of the Mobile Push SDK. Examples of how to do this are provided in the `MailDelegate.swift` and `BaseAppDelegate.swift` files. 

## Manual Integration Flow
The manual integration method is provided for those who need more control over the integration of the Mobile Push SDK then the automatic integration provides. At it's most basic, this simply requires executing three methods at the apropriate time in your Application Delegate.

In the `application(_:didFinishLaunchingWithOptions:)` method, of your Application Delegate, your code should also call `MCESdk.shared.handleApplicationLaunch()` if you are using an MceConfig.json file to provide configuration or  `MCESdk.shared.handleApplicationLaunch(withConfig:)` if not. This starts up the Mobile Push SDK on application startup. 

You should also register with APNS for remote notifications in this same method with `UIApplication.registerForRemoteNotifications()`. It does not prompt the user for permission, but does allow the Mobile Push registration to complete.  

You can ask for authorization from the user to present notifications at this time as well, however this will prompt the user for permissions. We recommend waiting to do this until the user has reached a point in your application that they will need notifications for that feature. Otherwise a user may reject the request out of hand, not knowing the benefits that you provide with push messges. This is done with the `UNUserNotificationCenter.requestAuthorization(options:completionHandler:)` method. Note, even without notification permission, the user is not inaccessible, silent pushes, inbox pushes and inapp pushes can still be used in this state.  

You can also override the user notification center delegate here if you need to respond to other types of push messages or need more control in the handling of push messages. An example of how to do that is provided in `NotificationDelegate.swift` 

At this point in your code, you can also register to handle actions. Registering your code to execute when actions execute is the best way to respond to actions by the user in push messages, inbox messages and inapp messages. This is done by calling the `MCEActionRegistry.shared.registerTarget(,with:,forAction:)` method of the Mobile Push SDK. Examples of how to do this are provided in the `MailDelegate.swift` and `BaseAppDelegate.swift` files. 

In the `application(_:didFailToRegisterForRemoteNotificationsWithError:)` method, of your Application Delegate, your code should also call `MCESdk.shared.deviceTokenRegistartionFailed()` to provide the Mobile Push SDK with the knowledge that something went wrong with the remote notification registration with APNS.

In the `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)` method, of your Application Deleate, your code should also call `MCESdk.shared.registerDeviceToken(deviceToken)` to provide the Mobile Push SDK with the device token assigned to your device by APNS.


# Notification Service Extension Target
This extension target provides the ability to send push messages with multiple actions and to attach media content to push messages. These must be done before the push is presented to the user and the notification service extension allows code to be run against a push message with the mutable content flag, before it is presented to the user. 

There are two main paths to integrate the Mobile Push SDK with your notification service extension. Both require the `AcousticMobilePushNotification.xcframework` to be included in the `Frameworks, Libraries, and Embedded Content` of the target with the  `Embed and sign` option selected.
 
## Automatic Integration Flow
To use the automatic integration flow in the notification service extension target, simply change the superclass of your Notification Service class to the `MCENotificationService` class and verify that the `MceConfig.json` file has been added to this target.  

## Manual Integration Flow
To manually configure the notification service extension when using the NSDictionary based configuration, be sure to initialize the MCEConfig object via `sharedInstanceWithDictionary` before creating the `MCENotificationService` object. Then in the `didReceive(_:withContentHandler:)` method call the mobile push method of the same name if the userInfo of the request contains a `notification-action`. Finally, in the `serviceExtensionTimeWillExpire()` method, be sure to call the mobile push method of the same name. See `NotificationService.swift` for an example of how to do this. 

# WatchOS Extension Target
There are two main paths to integrate the Mobile Push SDK with your watchOS extension. Both require the `AcousticMobilePushWatch.xcframework` to be included in the `Frameworks, Libraries, and Embedded Content` of the target with the  `Embed and sign` option selected.

Note, at this time, the MobilePush SDK does not support running a watchOS app without a bundled iOS app installation. If you have need of this functionality, please contact support with your use case.

Due to the design of watchOS extensions, there isn't an automatic integration flow available. However, integration is very simple for this case. If you're using an NSDictionary configuration, make sure to call `MCEWatchSdk.shared.applicationDidFinishLaunching(withConfig:)` in your `ExtensionDelegate.applicationDidFinishLaunching` method. If you're using an `MceConfig.json` file, simply use the  `MCEWatchSdk.shared.applicationDidFinishLaunching()` method instead. Note, if you're using the config file method, make sure the config file is available to this target.

Then, in the `applicationDidBecomeActive()` method and the `applicationWillResignActive()` method, make sure to call the `MCEWatchSdk` methods of the same name.
