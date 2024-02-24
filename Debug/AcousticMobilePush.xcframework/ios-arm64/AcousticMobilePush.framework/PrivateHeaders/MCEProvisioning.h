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

/** The MCEProvisioning class reads from the embedded.mobileprovision file in the application package to determine the environment that it is currently running on. */
@interface MCEProvisioning : NSObject

/** This method returns the singleton object of this class. */
@property(class, nonatomic, readonly) MCEProvisioning * _Nonnull sharedInstance NS_SWIFT_NAME(shared);

/** The certificateExpiration property specifies when the developer certificate expires. */
@property NSDate * _Nullable certificateExpiration;

/** The binaryEnvironment property specifies if the binary is running in the "debug", "ad-hoc", "enterprise", or "appstore" environment. */
@property NSString * _Nonnull binaryEnvironment;

/** The provisionedDevices property specifies the Device UDIDs that the binary is provisioned to run on. */
@property NSArray * _Nullable provisionedDevices;

/** The certificate expired method returns TRUE if the certificate is expired and FALSE otherwise. */
- (BOOL) certificateExpired;

/** The appGroups property contains the entitled app groups from the apps' entitlements file. */
@property NSArray<NSString*> * _Nullable appGroups;

@end
