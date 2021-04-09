/*
 * Copyright © 2015, 2020 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

import UIKit
import AcousticMobilePush

@objc class BaseAppDelegate : UIResponder, UIApplicationDelegate {
    var state: NSDictionary? = nil
    
    // Single Window Support (iOS ≤ 12)
    var window: UIWindow?
    
    func registerPlugins() {
        // MCE InApp Templates Plugins
        MCEInAppVideoTemplate.register()
        MCEInAppImageTemplate.register()
        MCEInAppBannerTemplate.register()

        // MCE Action Plugins
        DisplayWebViewPlugin.register()
        ActionMenuPlugin.register()
        AddToCalendarPlugin.register()
        AddToPassbookPlugin.register()
        SnoozeActionPlugin.register()
        ExamplePlugin.register()
        
#if TARGET_OS_IOS
        CarouselAction.registerPlugin()
#endif
        
        // MCE Inbox Templates Plugins
        MCEInboxActionPlugin.register()
        MCEInboxDefaultTemplate.register()
        MCEInboxPostTemplate.register()

        // Custom Send Email Plugin
        let mail = MailDelegate();
        MCEActionRegistry.shared.registerTarget(mail, with: #selector(mail.sendEmail(action:)), forAction: "sendEmail")
        
        TextInputActionPlugin.register()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        MCESdk.shared.registerDeviceToken(deviceToken)
    }
        
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let data = try? JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted), let string = String(data: data, encoding: .utf8) {
            print("Silent notification incoming: \(string)\n\n")
        } else {
            print("Silent notification incoming: <unknown format>")
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerPlugins()

        // Notificaiton Settings Support
        if #available(iOS 12.0, *) {
            MCESdk.shared.openSettingsForNotification = { notification in
                if let vc = MCESdk.shared.findCurrentViewController() {
                    let alert = UIAlertController(title: "Should show app settings for notifications", message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        
                    }))
                    vc.present(alert, animated: true, completion: {
                        
                    })
                } else {
                    print("Should show app settings for notifications")
                }
            }
        }
        
        inboxUpdate()
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.inboxUpdate), name:
            MCENotificationName.InboxCountUpdate.rawValue, object: nil)

        // This can be used to not present push notifications while app is running
        MCESdk.shared.presentNotification = {(userInfo) -> Bool in
            return true
        }
        
        UserDefaults.standard.register(defaults: ["action":"update", "standardType":"dial",  "standardDialValue":"\"8774266006\"",  "standardUrlValue":"\"http://acoustic.co\"",  "customType":"sendEmail",  "customValue":"{\"subject\":\"Hello from Sample App\",  \"body\": \"This is an example email body\",  \"recipient\":\"fake-email@fake-site.com\"}",  "categoryId":"example", "button1":"Accept", "button2":"Reject"])

        // Request APNS registration to send push messages
        application.registerForRemoteNotifications()
        
        // iOS 10+ Push Message Registration, some versions of iOS have different options available
        let options: UNAuthorizationOptions = {
            if #available(iOS 12.0, *) {
                return [.alert, .sound, .carPlay, .badge, .providesAppNotificationSettings]
            }
            return [.alert, .sound, .carPlay, .badge]
        }()

        // Request User Authentication to show notifications
        UNUserNotificationCenter.current().requestAuthorization(options: options, completionHandler: { (granted, error) in
            
            if let error = error {
                print("Couldn't request user authentication \(error.localizedDescription)")
                return
            }
            if granted {
                print("User provided authorization to show notifications")
            } else {
                print("User did not provide authorization to show notifications")
            }

            // Setup any app specific hardcoded notification categories, Acoustic push messages will create their own notification categores as needed to support the push message sent
            UNUserNotificationCenter.current().setNotificationCategories( self.notificationCategories() )
        })

        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            StateController.assemble(window: window)
            if let state = state {
                StateController.restore(state: state, toWindow: window)
            }
        }
        
        return true
    }
    
    func notificationCategories() -> Set<UNNotificationCategory> {
        // iOS 10+ Example static action category:
        let acceptAction = UNNotificationAction(identifier: "Accept", title: "Accept", options: [.foreground])
        let rejectAction = UNNotificationAction(identifier: "Reject", title: "Reject", options: [.destructive])
        let category = UNNotificationCategory(identifier: "example", actions: [acceptAction, rejectAction], intentIdentifiers: [], options: [.customDismissAction])
        
        return Set(arrayLiteral: category)
    }
    
    func isExampleCategory(userInfo: NSDictionary) -> Bool {
        if let aps = userInfo["aps"] as? NSDictionary, let category = aps["category"] as? String, category == "example" {
            return true
        }
        return false
    }

    @objc func inboxUpdate() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = Int(MCEInboxDatabase.shared.unreadMessageCount())
        }
    }
}

// iOS 13 Multiple Window Support
extension BaseAppDelegate {

    @available(macCatalyst 13.0, iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(macCatalyst 13.0, iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

// Custom URL Scheme Support
extension BaseAppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("URL delivered to application(_:open:options:)")
        let controller = UIAlertController(title: "Custom URL Clicked", message: url.absoluteString, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action) in
            
        }))
        window?.rootViewController?.present(controller, animated: true, completion: {
            
        })
        return true
    }
}

// iOS ≤12 State Restoration
extension BaseAppDelegate {
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        if let window = window, let state = StateController.state(forWindow: window) {
            coder.encode(state, forKey: "state")
            return true
        }
        return false
    }
        
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        if let state = coder.decodeObject(forKey: "state") as? NSDictionary, StateController.restorable(state: state) {
            self.state = state
            return true
        }
        
       return false
    }
}
