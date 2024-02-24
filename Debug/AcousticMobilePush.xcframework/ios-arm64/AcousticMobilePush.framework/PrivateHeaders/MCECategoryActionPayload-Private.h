//
// Copyright (C) 2024 Acoustic, L.P. All rights reserved.
//
// NOTICE: This file contains material that is confidential and proprietary to
// Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
// industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
// Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
// prohibited.
//

#import "MCECategoryActionPayload.h"
@import UserNotifications;

@interface MCECategoryActionPayload (Private)
@property (readonly) BOOL destructive;
@property (readonly) BOOL authentication;
@property (readonly) BOOL foreground;
@property (readonly) NSString * name;
@property (readonly) NSString * identifier;
-(UNNotificationActionOptions)options;
-(UNNotificationAction*)notificationAction;
@end
