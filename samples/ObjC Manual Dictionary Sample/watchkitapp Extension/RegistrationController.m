/*
 * Copyright © 2017, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "RegistrationController.h"

#if __has_feature(modules)
@import AcousticMobilePushWatch;
#else
#import <AcousticMobilePushWatch/AcousticMobilePushWatch.h>
#endif

@interface  RegistrationController()
@property id observer;
@end

@implementation RegistrationController

- (void)willDisappear
{
    [super willDisappear];
    [NSNotificationCenter.defaultCenter removeObserver:self.observer];
}

- (void)willActivate
{
    [super willActivate];
    [self updateRegistrationLabels];
    self.observer = [NSNotificationCenter.defaultCenter addObserverForName:MCERegisteredNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification*notification){
        [self updateRegistrationLabels];
    }];
}

-(void)updateRegistrationLabels
{
    if(MCERegistrationDetails.sharedInstance.mceRegistered)
    {
        [self.userIdLabel setText: MCERegistrationDetails.sharedInstance.userId];
        [self.channelIdLabel setText: MCERegistrationDetails.sharedInstance.channelId];
        [self.appKeyLabel setText: MCERegistrationDetails.sharedInstance.appKey];
    }
}

@end
