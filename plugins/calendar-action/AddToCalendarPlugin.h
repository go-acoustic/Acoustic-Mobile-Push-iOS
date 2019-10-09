/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#if __has_feature(modules)
@import Foundation;
@import EventKit;
@import EventKitUI;
@import AcousticMobilePush;
#else
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import <Foundation/Foundation.h>
#import <AcousticMobilePush/AcousticMobilePush.h>
#endif

NS_ASSUME_NONNULL_BEGIN
@interface AddToCalendarPlugin : NSObject <EKEventEditViewDelegate, MCEActionProtocol>
@property(class, nonatomic, readonly) AddToCalendarPlugin * sharedInstance NS_SWIFT_NAME(shared);
+(void)registerPlugin;
-(void)performAction:(NSDictionary*)action;
@end
NS_ASSUME_NONNULL_END
