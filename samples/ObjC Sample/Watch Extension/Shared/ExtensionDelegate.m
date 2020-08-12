/*
 * Copyright © 2017, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#if __has_feature(modules)
@import AcousticMobilePushWatch;
#else
#import <AcousticMobilePushWatch/AcousticMobilePushWatch.h>
#endif

#import "ExtensionDelegate.h"

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching {
    [MCEWatchSdk.sharedInstance applicationDidFinishLaunching];
    
    NSUInteger options = UNAuthorizationOptionAlert|UNAuthorizationOptionSound|UNAuthorizationOptionBadge|UNAuthorizationOptionCarPlay;
    [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions: options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        NSLog(@"Notifications response %d, %@", granted, error);
        [UNUserNotificationCenter.currentNotificationCenter setNotificationCategories: [NSSet set]];
    }];
}

- (void)applicationDidBecomeActive {
    [MCEWatchSdk.sharedInstance applicationDidBecomeActive];
}

- (void)applicationWillResignActive {
    [MCEWatchSdk.sharedInstance applicationWillResignActive];
}

@end
