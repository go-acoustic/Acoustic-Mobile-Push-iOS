//
// Copyright (C) 2024 Acoustic, L.P. All rights reserved.
//
// NOTICE: This file contains material that is confidential and proprietary to
// Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
// industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
// Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
// prohibited.
//

#if __has_feature(modules)
@import Foundation;
#else
#import <Foundation/Foundation.h>
#endif

#import "MCEDeliveryActionRegistry.h"
#import "MCEDeliveryReportAction.h"

@interface MCEDeliveryCertifyAction : MCEDeliveryReportAction <MCEDeliveryAction>
+(void)insertEventForActionPayload: (MCEDeliveryActionPayload*) actionPayload inNotificationPayload: (MCENotificationPayload*)notificationPayload origin: (NSString*)origin completion:(void (^)(void))callback;
@end
