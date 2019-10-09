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

-(void)performAction:(NSDictionary*)action payload:(NSDictionary*)payload
{
    if(![action respondsToSelector:@selector(isEqualToDictionary:)]) {
        NSLog(@"Action is not a dictionary");
        return;
    }
    
    id value = action[@"value"];
    int minutes;
    if(value && [value respondsToSelector:@selector(intValue)]) {
        minutes = [value intValue];
    } else {
        NSLog(@"Invalid value in action payload");
        return;
    }
    
    NSLog(@"Snooze for %d minutes", minutes);
    
    NSString * alertAction = nil;
    if([payload[@"aps"][@"alert"] respondsToSelector:@selector(isEqualToDictionary:)] && payload[@"aps"][@"alert"][@"action-loc-key"]) {
        alertAction = payload[@"aps"][@"alert"][@"action-loc-key"];
    }
    
    NSString * category = payload[@"aps"][@"category"];
    NSString * alertBody = [[MCESdk sharedInstance] extractAlert:payload[@"aps"]];
    NSNumber * badge = payload[@"aps"][@"badge"];
    NSString * sound = payload[@"aps"][@"sound"];
    NSString * title = payload[@"aps"][@"title"];
    NSString * subtitle = payload[@"aps"][@"subtitle"];
    
    if (@available(iOS 10.0, *)) {
        UNTimeIntervalNotificationTrigger * trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:minutes*60 repeats:false];
        UNMutableNotificationContent * content = [[UNMutableNotificationContent alloc] init];
        UNNotificationRequest * request = [UNNotificationRequest requestWithIdentifier:[[NSUUID UUID] UUIDString] content:content trigger:trigger];
        
        if(payload && [payload respondsToSelector:@selector(isEqualToDictionary:)] ) {
            content.userInfo = payload;
        }
                       
        if(category && [category respondsToSelector:@selector(isEqualToString:)]) {
            content.categoryIdentifier = category;
        }
        
        if(sound && [sound respondsToSelector:@selector(isEqualToString:)]) {
            if([sound isEqual: @"default"]) {
                content.sound = [UNNotificationSound defaultSound];
            } else {
                content.sound = [UNNotificationSound soundNamed: sound];
            }
        }
        
        if(badge && [badge respondsToSelector:@selector(isEqualToNumber:)]) {
            content.badge = badge;
        }
        
        if(alertBody && [alertBody respondsToSelector:@selector(isEqualToString:)] ) {
            content.body = alertBody;
        }

        if(title && [title respondsToSelector:@selector(isEqualToString:)] ) {
            content.title = title;
        }

        if(subtitle && [subtitle respondsToSelector:@selector(isEqualToString:)] ) {
            content.subtitle = subtitle;
        }

        [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if(error) {
                NSLog(@"Could not add notification request");
            }
        }];

    } else {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UILocalNotification * notification = [[UILocalNotification alloc] init];
        
        if(payload && [payload respondsToSelector:@selector(isEqualToDictionary:)] ) {
            notification.userInfo = payload;
        }
        
        if(category && [category respondsToSelector:@selector(isEqualToString:)]) {
            notification.category = category;
        }

        if(sound && [sound respondsToSelector:@selector(isEqualToString:)]) {
            notification.soundName = sound;
        }
        
        if(badge && [badge respondsToSelector:@selector(isEqualToNumber:)]) {
            notification.applicationIconBadgeNumber = [badge integerValue];
        }
        
        if(alertAction && [alertAction respondsToSelector:@selector(isEqualToString:)]) {
            notification.alertAction = alertAction;
            notification.hasAction = true;
        } else {
            notification.hasAction = false;
        }
        
        if(title && [title respondsToSelector:@selector(isEqualToString:)] ) {
            notification.alertTitle = title;
        }
        
        if(alertBody && [alertBody respondsToSelector:@selector(isEqualToString:)] ) {
            notification.alertBody = alertBody;
        }

        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:minutes*60];
        [[UIApplication sharedApplication] scheduleLocalNotification: notification];
        #pragma clang diagnostic pop
    }
}

+(void)registerPlugin
{
    MCEActionRegistry * registry = [MCEActionRegistry sharedInstance];
    [registry registerTarget: [self sharedInstance] withSelector:@selector(performAction:payload:) forAction: @"snooze"];
}

@end
