//
//  AppDelegate.swift
//  TestUI
//
//  Created by Jeremy Buchman on 8/2/19.
//  Copyright © 2019 Jeremy Buchman. All rights reserved.
//

import UIKit

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        application.registerForRemoteNotifications()
        let options: UNAuthorizationOptions = [.alert, .sound, .carPlay, .badge, .providesAppNotificationSettings]
        UNUserNotificationCenter.current().requestAuthorization(options: options, completionHandler: { (granted, error) in
            if let error = error {
                print("Could not request authorization from APNS \(error.localizedDescription)")
                return
            }
            if granted {
                print("Push auth granted")
            } else {
                print("Push auth denied")
            }
        })
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

