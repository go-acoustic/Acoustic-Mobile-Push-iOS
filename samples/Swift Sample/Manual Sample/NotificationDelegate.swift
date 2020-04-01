/*
* Copyright © 2020 Acoustic, L.P. All rights reserved.
*
* NOTICE: This file contains material that is confidential and proprietary to
* Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
* industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
* Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
* prohibited.
*/

import Foundation

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    // This method processes the notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard response.notification.request.content.userInfo["notification-action"] == nil else {
            MCENotificationDelegate.shared.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
            return
        }
        // handle other types of notifications here
    }

    // This method is used to determine if the notification should be shown to the user when the app is running
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard notification.request.content.userInfo["notification-action"] == nil else {
            MCENotificationDelegate.shared.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
            return
        }

        // handle other types of notifications here, typically via
        completionHandler([.alert, .sound, .badge])
    }

}
