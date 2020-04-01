/*
* Copyright © 2020 Acoustic, L.P. All rights reserved.
*
* NOTICE: This file contains material that is confidential and proprietary to
* Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
* industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
* Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
* prohibited.
*/

import UIKit
import AcousticMobilePush

// See BaseAppDelegate
@UIApplicationMain
class AppDelegate: BaseAppDelegate {

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // If using the MceConfig.json file:
        //MCESdk.shared.handleApplicationLaunch()
        
        // If providing the config via a NSDictionary
        MCESdk.shared.handleApplicationLaunch(withConfig: Config.mobilePushConfig)

        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared;
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError \(error.localizedDescription)")
        MCESdk.shared.deviceTokenRegistartionFailed()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("DeviceToken: \( MCEApiUtil.deviceToken(deviceToken) ?? "" )")
        MCESdk.shared.registerDeviceToken(deviceToken)
    }
}
