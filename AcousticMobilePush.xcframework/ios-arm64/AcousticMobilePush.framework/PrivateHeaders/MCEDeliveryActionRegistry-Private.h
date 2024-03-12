//
// Copyright (C) 2024 Acoustic, L.P. All rights reserved.
//
// NOTICE: This file contains material that is confidential and proprietary to
// Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
// industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
// Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
// prohibited.
//
#import "MCEDeliveryActionRegistry.h"

@interface MCEDeliveryActionRegistry (Private)
@property(class, nonatomic, readonly) MCEDeliveryActionRegistry * _Nonnull sharedInstance NS_SWIFT_NAME(shared);
-(void)registerDeliveryAction: (id <MCEDeliveryAction>_Nonnull) handler forType: (NSString * _Nonnull)type;
-(void)processDeliveryActionPayload: (MCEDeliveryActionPayload * _Nonnull) actionPayload inNotificationPayload: (MCENotificationPayload * _Nonnull) notificationPayload origin: (NSString* _Nonnull) origin completion: (void (^_Nullable)(void))callback;
@end
