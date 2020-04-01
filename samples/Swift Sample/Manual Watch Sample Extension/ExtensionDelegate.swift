/*
* Copyright © 2017, 2020 Acoustic, L.P. All rights reserved.
*
* NOTICE: This file contains material that is confidential and proprietary to
* Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
* industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
* Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
* prohibited.
*/

import WatchKit
import UserNotifications
import AcousticMobilePushWatch

class ExtensionDelegate: NSObject, WKExtensionDelegate {
    func applicationDidFinishLaunching() {
        MCEWatchSdk.shared.applicationDidFinishLaunching(withConfig: Config.mobilePushConfig)

        // iOS 10+ Push Message Registration
        let options: UNAuthorizationOptions = {
            if #available(watchOS 5.0, *) {
                return [.alert, .sound, .carPlay, .badge, .providesAppNotificationSettings]
            }
            return [.alert, .sound, .carPlay, .badge]
        }()

        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            
        }
    }
    
    func applicationDidBecomeActive() {
        MCEWatchSdk.shared.applicationDidBecomeActive()
    }
    
    func applicationWillResignActive() {
        MCEWatchSdk.shared.applicationWillResignActive()
    }
}
