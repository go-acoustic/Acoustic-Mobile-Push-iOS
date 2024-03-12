//
// Copyright (C) 2024 Acoustic, L.P. All rights reserved.
//
// NOTICE: This file contains material that is confidential and proprietary to
// Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
// industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
// Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
// prohibited.
//
//
// Created by Feras on 7/29/13.
// 

#if defined(TARGET_OS_WATCH) && TARGET_OS_WATCH

#if __has_feature(modules)
@import Foundation;
@import CoreLocation;
#else
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#endif

#else

#if __has_feature(modules)
@import UIKit;
@import CoreLocation;
#else
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#endif

#endif


@interface MCEPersistentStorage : NSObject
@property(class, nonatomic, readonly) MCEPersistentStorage * _Nonnull sharedInstance NS_SWIFT_NAME(shared);
@property (readonly) NSDate * _Nonnull installDate;
@property (readonly) NSString * _Nonnull installId;

@property NSDate * _Nullable lastInvalidateUser;
@property NSString * _Nullable lastLocationSync;
@property NSString * _Nullable timezone;
@property NSString * _Nullable appKey;
@property NSString * _Nullable osVersion;
@property NSString * _Nullable deviceModel;
@property NSString * _Nullable sdkVersion;
@property NSString * _Nullable applicationVersion;
@property NSString * _Nullable formFactor;
#if !TARGET_OS_WATCH && !TARGET_OS_MACCATALYST
@property NSString * _Nullable carrierName;
#endif
@property NSString * _Nullable locale;

#if TARGET_OS_WATCH==0
@property CLLocationCoordinate2D referenceLocation;
#endif
@property BOOL pushEnabled;
@property NSDate * _Nullable lastInboxSync;
@property NSDate * _Nullable lastLocationSyncStart;

@property NSNumber * _Nullable visitOperationVersion;
@property NSNumber * _Nullable placeVisitVersion;
@property NSNumber * _Nullable placeDailyVisitVersion;
@property NSNumber * _Nullable placeVersion;
@property NSNumber * _Nullable customVersion;
@property NSNumber * _Nullable customRuleVersion;
@property NSDate * _Nullable lastInboxSyncStart;
@property NSString * _Nullable iBeaconEnabled;
@property NSString * _Nullable geofenceEnabled;

@property NSData * _Nullable sentPushToken;
@property NSDate * _Nullable sessionStart;
@property NSDate * _Nullable sessionEnd;
@property NSDate * _Nullable sessionTimeout;
@property BOOL sdkInitialized;
@property BOOL locationInitialized;

@property NSDate * _Nullable lastPhoneHome;
@property NSInteger phoneHomeFrequency;

@property NSString * _Nullable userId;
@property NSString * _Nullable channelId;
@property NSData * _Nullable pushToken;

@property BOOL userInvalidated;

- (void) clearPersistentStorage;

- (id _Nullable) getPersistentValueForKey: (NSString * _Nonnull) key;
- (void) setPersistentValue: (id _Nullable) value forKey: (NSString * _Nonnull) key;
+ (BOOL) isSharedInstanceInitialized;

@end
