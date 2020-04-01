/*
 * Copyright © 2016, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "NotificationService.h"
#import "Config.h"

#if __has_feature(modules)
@import UserNotifications;
@import AcousticMobilePushNotification;
#else
#import <UserNotifications/UserNotifications.h>
#import <AcousticMobilePushNotification/AcousticMobilePushNotification.h>
#endif

@implementation NotificationService

-(instancetype)init {
    if(self = [super init]) {
        [MCEConfig sharedInstanceWithDictionary: Config.mobilePushConfig];
        self.notificationService = [[MCENotificationService alloc] init];
    }
    return self;
}

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    if(request.content.userInfo[@"notification-action"]) {
        [self.notificationService didReceiveNotificationRequest: request withContentHandler: contentHandler];
        return;
    }
    
    // Process your push notifications here
}

- (void)serviceExtensionTimeWillExpire {
    [self.notificationService serviceExtensionTimeWillExpire];
    
    // Process your push notifications here
}

@end
