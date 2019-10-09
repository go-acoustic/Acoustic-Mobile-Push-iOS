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
@import AcousticMobilePush;
#else
#import <Foundation/Foundation.h>
#import <AcousticMobilePush/AcousticMobilePush.h>
#endif

#import "AddToPassbookClient.h"

NS_ASSUME_NONNULL_BEGIN
@interface AddToPassbookPlugin : NSObject <PKAddPassesViewControllerDelegate, MCEActionProtocol>
@property AddToPassbookClient * client;
@property(class, nonatomic, readonly) AddToPassbookPlugin * sharedInstance NS_SWIFT_NAME(shared);
+(void)registerPlugin;
-(void)performAction:(NSDictionary*)action;
@end
NS_ASSUME_NONNULL_END
