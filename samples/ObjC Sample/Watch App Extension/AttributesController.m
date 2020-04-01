/*
 * Copyright © 2017, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "AttributesController.h"

#if __has_feature(modules)
@import AcousticMobilePushWatch;
#else
#import <AcousticMobilePushWatch/AcousticMobilePushWatch.h>
#endif

@interface AttributesController ()
@property NSMutableArray * listeners;
@property NSTimer * deleteTimer;
@property NSTimer * updateTimer;
@end

@implementation AttributesController

-(IBAction)updateAttribute:(id)sender
{
    [self.updateAttributeStatus setText:@"Sending"];
    [self.updateAttributeStatus setTextColor:UIColor.whiteColor];
    NSLog(@"Attribute Status %@", self.updateAttributeStatus);
    [[MCEAttributesQueueManager sharedInstance] updateUserAttributes:@{@"onwatch": @(arc4random())}];
}

-(IBAction)deleteAttribute:(id)sender
{
    [self.deleteAttributeStatus setText:@"Sending"];
    [self.deleteAttributeStatus setTextColor:UIColor.whiteColor];
    NSLog(@"Attribute Status %@", self.deleteAttributeStatus);
    [[MCEAttributesQueueManager sharedInstance] deleteUserAttributes:@[@"onwatch"]];
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    arc4random_stir();
    self.listeners = [NSMutableArray array];
}

- (void)didDeactivate
{
    [super didDeactivate];
    for (id listener in self.listeners) {
        [NSNotificationCenter.defaultCenter removeObserver:listener];
    }
}

-(void)willActivate
{
    [super willActivate];
    
    [self.listeners addObject: [NSNotificationCenter.defaultCenter addObserverForName:UpdateUserAttributesError object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        if(note.userInfo[@"attributes"][@"onwatch"])
        {
            [self.updateAttributeStatus setText:@"Error"];
            [self.updateAttributeStatus setTextColor:UIColor.redColor];
        }
    }]];
    
    [self.listeners addObject: [NSNotificationCenter.defaultCenter addObserverForName:UpdateUserAttributesSuccess object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        if(note.userInfo[@"attributes"][@"onwatch"])
        {
            [self.updateAttributeStatus setText:@"Received"];
            [self.updateAttributeStatus setTextColor:UIColor.greenColor];

            if(self.updateTimer)
            {
                [self.updateTimer invalidate];
            }
            self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
                [self.updateAttributeStatus setTextColor:UIColor.lightGrayColor];
                [self.updateAttributeStatus setText: @"Idle"];
                self.updateTimer = nil;
            }];
        }
    }]];
    
    [self.listeners addObject: [NSNotificationCenter.defaultCenter addObserverForName:DeleteUserAttributesError object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        if([note.userInfo[@"keys"] indexOfObject: @"onwatch"] != NSNotFound)
        {
            [self.deleteAttributeStatus setText:@"Error"];
            [self.deleteAttributeStatus setTextColor:UIColor.redColor];
        }
    }]];
    
    [self.listeners addObject: [NSNotificationCenter.defaultCenter addObserverForName:DeleteUserAttributesSuccess object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        if([note.userInfo[@"keys"] indexOfObject: @"onwatch"] != NSNotFound)
        {
            [self.deleteAttributeStatus setText:@"Received"];
            [self.deleteAttributeStatus setTextColor:UIColor.greenColor];
            
            if(self.deleteTimer)
            {
                [self.deleteTimer invalidate];
            }
            self.deleteTimer = [NSTimer scheduledTimerWithTimeInterval:5 repeats:NO block:^(NSTimer * _Nonnull timer) {
                [self.deleteAttributeStatus setTextColor:UIColor.lightGrayColor];
                [self.deleteAttributeStatus setText:@"Idle"];
                self.deleteTimer = nil;
            }];
        }
    }]];
}

@end
