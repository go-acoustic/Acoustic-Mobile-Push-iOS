/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "SnoozeActionPlugin.h"
@import UserNotifications;
@import AcousticMobilePush;

@interface SnoozeActionPlugin ()
@property MCENotificationPayload * notificationPayload;
@end

@implementation SnoozeActionPlugin

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)performAction:(NSDictionary*)action payload:(NSDictionary*)payload {
    NSNumber * value = action[@"value"];
    if(![value respondsToSelector:@selector(isEqualToNumber:)]) {
        NSLog(@"Snooze value is not numeric");
        return;
    }
            
    NSLog(@"Snooze for %f minutes", [value doubleValue]);

    self.notificationPayload = [[MCENotificationPayload alloc] initWithPayload: payload];
    [self.notificationPayload addNotificationCategoryWithCompletionHandler:^{
        UNMutableNotificationContent * content = SnoozeActionPlugin.sharedInstance.notificationPayload.notificationContent;
        UNTimeIntervalNotificationTrigger * trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:[value doubleValue] * 60 repeats:false];
        UNNotificationRequest * request = [UNNotificationRequest requestWithIdentifier:[[NSUUID UUID] UUIDString] content:content trigger:trigger];
        [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            
            if(error) {
                NSLog(@"Could not add notification request");
            } else {
                NSLog(@"Will resend notification %@ with content %@ at %@", request, content, [trigger nextTriggerDate]);
            }
        }];

    }];
}

+(void)registerPlugin
{
    MCEActionRegistry * registry = [MCEActionRegistry sharedInstance];
    [registry registerTarget: [self sharedInstance] withSelector:@selector(performAction:payload:) forAction: @"snooze"];
}

@end
