/*
 * Copyright © 2016, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "NotificationDelegate.h"

#if __has_feature(modules)
@import AcousticMobilePush;
#else
#import <AcousticMobilePush/AcousticMobilePush.h>
#endif

@implementation NotificationDelegate

#pragma mark This method defines if the notification should be shown to the user while the app is open (iOS ≥ 10)
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler;
{
    // Acoustic Integration
    NSDictionary * userInfo = notification.request.content.userInfo;
    if(!MCESdk.sharedInstance.presentNotification || MCESdk.sharedInstance.presentNotification(userInfo))
    {
        completionHandler(UNNotificationPresentationOptionAlert+UNNotificationPresentationOptionSound+UNNotificationPresentationOptionBadge);
    }
    else
    {
        completionHandler(0);
    }
}

#pragma mark Remote or Local notification or notification action clicked, potentially with text input (iOS ≥ 10)
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler;
{
    // Acoustic Integration
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    
    [[MCEInAppManager sharedInstance] processPayload: userInfo];
    
    if([response.actionIdentifier isEqual:UNNotificationDefaultActionIdentifier])
    {
        [[MCESdk sharedInstance] performNotificationAction: userInfo];
    }
    else if([response.actionIdentifier isEqual:UNNotificationDismissActionIdentifier])
    {
    }
    else if([response isKindOfClass:[UNTextInputNotificationResponse class]])
    {
        UNTextInputNotificationResponse * textResponse = (UNTextInputNotificationResponse*)response;
        [[MCESdk sharedInstance] processDynamicCategoryNotification: userInfo identifier:response.actionIdentifier userText: textResponse.userText];
    }
    else
    {
        [[MCESdk sharedInstance] processDynamicCategoryNotification: userInfo identifier:response.actionIdentifier userText: nil];
    }
        
    completionHandler();
}

@end
