/*
 * Copyright © 2016, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "WatchNotificationDelegate.h"

#if __has_feature(modules)
@import AcousticMobilePushWatch;
#else
#import <AcousticMobilePushWatch/AcousticMobilePushWatch.h>
#endif

@implementation WatchNotificationDelegate

#pragma mark This method defines if the notification should be shown to the user while the app is open
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler;
{
    // Acoustic Integration
    NSDictionary * userInfo = notification.request.content.userInfo;
    if(!MCEWatchSdk.sharedInstance.presentNotification || MCEWatchSdk.sharedInstance.presentNotification(userInfo))
    {
        completionHandler(UNNotificationPresentationOptionAlert+UNNotificationPresentationOptionSound+UNNotificationPresentationOptionBadge);
        NSLog(@"User notification presenting %@", userInfo);
    }
    else
    {
        completionHandler(0);
        NSLog(@"Not presenting to user because application presentNotification returned FALSE");
    }
}

#pragma mark Remote or Local notification or notification action clicked, potentially with text input
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler __IOS_AVAILABLE(10.0) __WATCHOS_AVAILABLE(3.0) __TVOS_PROHIBITED
{
    // Acoustic Integration
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    NSLog(@"User notification received %@", userInfo);
    
    if([response.actionIdentifier isEqual:UNNotificationDefaultActionIdentifier])
    {
        [MCEWatchSdk.sharedInstance performNotificationAction: userInfo];
    }
    else if(response.actionIdentifier)
    {
        [MCEWatchSdk.sharedInstance performNotificationAction: userInfo identifier:response.actionIdentifier];
    }
    
    completionHandler();
}

@end

