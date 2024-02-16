//
// Copyright (C) 2024 Acoustic, L.P. All rights reserved.
//
// NOTICE: This file contains material that is confidential and proprietary to
// Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
// industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
// Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
// prohibited.
//

#import <Foundation/Foundation.h>

//! Project version number for AcousticMobilePush.
FOUNDATION_EXPORT double AcousticMobilePushVersionNumber;

//! Project version string for AcousticMobilePush.
FOUNDATION_EXPORT const unsigned char AcousticMobilePushVersionString[];

#import "MCEActionRegistry.h"
#import "MCEApiUtil.h"
#import "MCEAppDelegate.h"
#import "MCEArea.h"
#import "MCEAttributesQueueManager.h"
#import "MCECallbackDatabaseManager.h"
#import "MCECategoryActionPayload.h"
#import "MCEClient.h"
#import "MCEConfig.h"
#import "MCEConstants.h"
#import "MCEDeliveryActionPayload.h"
#import "MCEDeliveryCertifyAction.h"
#import "MCEEvent.h"
#import "MCEEventService.h"
#import "MCEGeofence.h"
#import "MCEGeofenceManager.h"
#import "MCEInAppManager.h"
#import "MCEInAppMessage.h"
#import "MCEInAppTemplate.h"
#import "MCEInAppTemplateRegistry.h"
#import "MCEInboxDatabase.h"
#import "MCEInboxMessage.h"
#import "MCEHelper.h"
#import "MCEInboxQueueManager.h"
#import "MCELocationClient.h"
#import "MCELocationDatabase.h"
#import "MCELog.h"
#import "MCENotificationActionPayload.h"
#import "MCENotificationDelegate.h"
#import "MCENotificationPayload.h"
#import "MCEPayload.h"
#import "MCEPhoneHomeManager.h"
#import "MCERegistrationDetails.h"
#import "MCESdk.h"
#import "MCETemplate.h"
#import "MCETemplateRegistry.h"
#import "UIColor+Hex.h"


#import "MCENotificationPayload-Private.h"
#import "MCEPayload-Private.h"
#import "MCEProvisioning.h"
#import "MCEDeliveryReportAction.h"
#import "MCEDeliveryActionRegistry.h"
#import "MCEPersistentStorage.h"
#import "MCESdk-Private.h"
#import "MCEConfig-Private.h"
