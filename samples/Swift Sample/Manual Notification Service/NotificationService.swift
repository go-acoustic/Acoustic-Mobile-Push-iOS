/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

import UserNotifications
import AcousticMobilePushNotification

class NotificationService: UNNotificationServiceExtension {
    let mobilePushNotificationService: MCENotificationService
    override init() {
        // If using a dictionary based configuration:
        MCEConfig.sharedInstance(with: Config.mobilePushConfig)
        
        // If using the MceConfig.json file, you only need to initialize the object
        mobilePushNotificationService = MCENotificationService()
        super.init()
    }
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        if request.content.userInfo["notification-action"] != nil {
            mobilePushNotificationService.didReceive(request, withContentHandler: contentHandler)
            return
        }
        
        // Handle other notifications here
    }
    
    override func serviceExtensionTimeWillExpire() {
        mobilePushNotificationService.serviceExtensionTimeWillExpire()
    }
}
