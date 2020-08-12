/*
* Copyright © 2020 Acoustic, L.P. All rights reserved.
*
* NOTICE: This file contains material that is confidential and proprietary to
* Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
* industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
* Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
* prohibited.
*/

#import "NotificationDelegate.h"

@interface MCENotificationDelegate : NSObject <UNUserNotificationCenterDelegate>
+ (instancetype)sharedInstance;
@end

@implementation NotificationDelegate

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(nullable UNNotification *)notification __API_AVAILABLE(macos(10.14), ios(12.0)) __API_UNAVAILABLE(watchos, tvos) {
    // Present UI to select notification preferences in app, or don't implement this method
}

// Method called by OS when a push is rec'd and the app is open
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {

    if(notification.request.content.userInfo[@"notification-action"]) {
        [MCENotificationDelegate.sharedInstance userNotificationCenter: center willPresentNotification: notification withCompletionHandler: completionHandler];
        return;
    }
    
    // Handle your push message here
    
    // To show the push message while app is open:
    completionHandler(UNNotificationPresentationOptionAlert + UNNotificationPresentationOptionSound + UNNotificationPresentationOptionBadge);
    
    // To hide the push message while app is open:
    //completionHandler(0);
}

// Method called by OS when a push is tapped by a user
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler API_AVAILABLE(macos(10.14), ios(10.0), watchos(3.0), tvos(10.0)) {

    if(response.notification.request.content.userInfo[@"notification-action"]) {
        [MCENotificationDelegate.sharedInstance userNotificationCenter: center didReceiveNotificationResponse: response withCompletionHandler: completionHandler];
        return;
    }
    
    // Handle your push message here
}

@end
