/*
 * Copyright © 2017, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */
 
#import "HandOffController.h"

@interface HandOffController ()
@property id backgroundListener;
@end

@implementation HandOffController

- (void)awakeWithContext:(NSDictionary*)context {
    // You can customize the look and feel of the handoff from here
    // action is a NSDictionary with the context["action"] payload, you could
    // potentially display a different message depending on the type
    // of action that was handed off. Or even automatically dismiss
    // the controller after a specified amount of time.
    
    self.backgroundListener = [NSNotificationCenter.defaultCenter addObserverForName:NSExtensionHostWillResignActiveNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        [NSNotificationCenter.defaultCenter removeObserver:self.backgroundListener];
        self.backgroundListener = nil;
        [self dismissController];
    }];
    
}

-(void)willDisappear
{
    if([WKExtension.sharedExtension.visibleInterfaceController isEqual: self])
    {
        [self dismissController];
    }
    [super willDisappear];
    if(self.backgroundListener)
    {
        [NSNotificationCenter.defaultCenter removeObserver:self.backgroundListener];
        self.backgroundListener = nil;
    }
}

-(IBAction)dismiss:(id)sender
{
    [self dismissController];
}

@end
