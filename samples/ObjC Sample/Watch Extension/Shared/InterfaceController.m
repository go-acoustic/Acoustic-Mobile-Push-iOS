/*
 * Copyright © 2017, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#if __has_feature(modules)
@import AcousticMobilePushWatch;
#else
#import <AcousticMobilePushWatch/AcousticMobilePushWatch.h>
#endif

#import "InterfaceController.h"

@interface InterfaceController ()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [self.versionLabel setText: MCEWatchSdk.sharedInstance.sdkVersion];
    [super awakeWithContext:context];
}

@end
