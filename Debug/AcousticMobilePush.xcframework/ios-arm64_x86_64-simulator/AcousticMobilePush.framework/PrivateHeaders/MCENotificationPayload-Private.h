//
// Copyright (C) 2024 Acoustic, L.P. All rights reserved.
//
// NOTICE: This file contains material that is confidential and proprietary to
// Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
// industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
// Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
// prohibited.
//

#import "MCENotificationPayload.h"

@class MCEDatabase;
@class MCEDeliveryActionPayload;

@interface MCENotificationPayload (Private)
- (void) downloadMediaAttachmentWithCompletionHandler: ( void (^ _Nullable)(UNNotificationAttachment * _Nullable attachment)) completionHandler;
- (NSString * _Nonnull) categoryName;
- (NSNumber * _Nullable) mailingId;
- (NSArray<MCEDeliveryActionPayload *> * _Nullable) payloadActions;
- (NSString * _Nullable) attribution;
- (void) processPayloadActionsWithOrigin: (NSString * _Nonnull) origin completionHandler: ( void (^_Nullable)(void)) completionHandler;
- (void) presentNotificationOrigin: (NSString * _Nonnull) origin completionHandler: ( void (^_Nullable)(void)) completionHandler;
- (MCEDeliveryActionPayload * _Nullable) certifyActionPayload;
-(BOOL) contentAvailable;
@end
