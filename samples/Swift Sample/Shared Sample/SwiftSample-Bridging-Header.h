/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

// MCE Action Plugins
#import "ActionMenuPlugin.h"
#import "AddToCalendarPlugin.h"
#import "AddToPassbookPlugin.h"
#import "SnoozeActionPlugin.h"
#import "DisplayWebViewPlugin.h"
#import "ExamplePlugin.h"
#import "CarouselAction.h"

// MCE Inbox Template Plugins
#import "MCEInboxActionPlugin.h"
#import "MCEInboxDefaultTemplate.h"
#import "MCEInboxPostTemplate.h"

// MCE InApp Template Plugins
#import "MCEInAppVideoTemplate.h"
#import "MCEInAppImageTemplate.h"
#import "MCEInAppBannerTemplate.h"

#import "TextInputActionPlugin.h"

#import "MCEInboxTableViewController.h"

#if __has_feature(modules)
@import UserNotifications;
#else
#import <UserNotifications/UserNotifications.h>
#endif
