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
@import WatchKit;
@import Foundation;
@import WatchConnectivity;
#else
#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>
#endif

/** The MCEWatchSdk class is the central integration point for the Watch SDK as a whole. */
@interface MCEWatchSdk: NSObject <WCSessionDelegate>

/** This method returns the singleton object of this class. */
@property(class, nonatomic, readonly) MCEWatchSdk * _Nonnull sharedInstance NS_SWIFT_NAME(shared);

/** Get the current SDK Version number as a string. */
- (NSString * _Nonnull) sdkVersion;

/** This method should be called from the watch extension delegate's applicationWillResignActive method */
- (void)applicationWillResignActive;

/** This method should be called from the watch extension delegate's applicationDidBecomeActive method */
- (void)applicationDidBecomeActive;

/** This method should be called from the watch extension delegate's applicationDidFinishLaunching method */
- (void)applicationDidFinishLaunching;

/** This property can be used to override if a notification is delivered to the device when the app is running. */
@property (nonatomic, assign) BOOL (^ _Nullable presentNotification)(NSDictionary * _Nonnull userInfo);

/** This method will execute the category action referenced by the identified notification action. */
-(void) performNotificationAction: (NSDictionary * _Nonnull) userInfo identifier: (NSString * _Nonnull) identifier;

/** This method will execute the notification action in the userInfo dictionary */
-(void) performNotificationAction: (NSDictionary * _Nonnull) userInfo;

- (void)applicationDidFinishLaunchingWithConfig: (NSDictionary * _Nullable) config;

@end

