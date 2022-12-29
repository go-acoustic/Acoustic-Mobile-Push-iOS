/*
 * Copyright © 2011, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */
#import "MainVC.h"

#if __has_feature(modules)
@import AcousticMobilePush;
#else
#import <AcousticMobilePush/AcousticMobilePush.h>
#endif

@interface MainVC ()
@property NSTimer * syncTimer;
@property int syncSecondsRemaining;
@end

@implementation MainVC

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self inboxUpdate];
    [self checkSyncTimer];
}

// Hide iBeacons when on Mac
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!NSClassFromString(@"iBeaconVC") && indexPath.item == 7) {
        return 0;
    }

    return 44;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // iOS 13 Multiple Window Support
    if(@available(iOS 13.0, *)) {
        if(UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPad) {
            self.view.window.windowScene.userActivity = [[NSUserActivity alloc] initWithActivityType: @"co.acoustic.mobilepush"];
            self.view.window.windowScene.userActivity.title = NSStringFromClass(self.class);
        }
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // iOS 13 Multiple Window Support
    if(@available(iOS 13.0, *)) {
        self.view.window.windowScene.userActivity = nil;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.version setText: [NSString stringWithFormat: @"Native SDK v%@", MCESdk.sharedInstance.sdkVersion]];
    
    // Show Inbox counts on main page
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inboxUpdate) name: InboxCountUpdate object:nil];
    if(MCERegistrationDetails.sharedInstance.mceRegistered)
    {
        [[MCEInboxQueueManager sharedInstance] syncInbox];
    }
    else
    {
        [NSNotificationCenter.defaultCenter addObserverForName: MCERegisteredNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
            [[MCEInboxQueueManager sharedInstance] syncInbox];
        }];
    }
}

// Show Inbox counts on main page
-(void)inboxUpdate
{
    int unreadCount = [[MCEInboxDatabase sharedInstance] unreadMessageCount];
    int messageCount = [[MCEInboxDatabase sharedInstance] messageCount];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString * subtitle = @"";
        if(MCERegistrationDetails.sharedInstance.mceRegistered)
        {
            subtitle = [NSString stringWithFormat:@"%d messages, %d unread", messageCount, unreadCount];
        }
        self.inboxCell.detailTextLabel.text = subtitle;
        self.altInboxCell.detailTextLabel.text = subtitle;
        [self.tableView reloadData];
    });
}

-(void)checkSyncTimer
{
    NSDate * lastSync = MCESdk.sharedInstance.lastInboxSync == nil ? [NSDate date] : MCESdk.sharedInstance.lastInboxSync;
    if(self.syncTimer == nil && lastSync != nil){
        int secondsElapsed = [[NSDate date] timeIntervalSinceDate:lastSync];
        int maxTimeout = MCESdk.sharedInstance.config.locationSyncTimeout;
        int timeRemaining = maxTimeout - secondsElapsed;
        self.syncSecondsRemaining = timeRemaining;
        [self startSyncTimer];
    }
}

// Start the sync timer
-(void)startSyncTimer
{
    self.syncTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                     target:self
                                                   selector:@selector(updateSyncLabel:)
                                                   userInfo:nil
                                                    repeats:YES];
    
}


- (void)updateSyncLabel:(NSTimer *)timer {
    if (self.syncSecondsRemaining > 0) {
        self.syncLabel.text = [NSString stringWithFormat:@"%s %@%s","Sync Available In:", [NSString stringWithFormat:@"%ld",(long)self.syncSecondsRemaining], "s"];
        self.syncLabel.textColor = [UIColor blackColor];
    }else{
        self.syncLabel.text = @"Sync Available";
        self.syncLabel.textColor = [UIColor greenColor];
        [self.syncTimer invalidate];
        self.syncTimer = nil;
    }
    // decrement the number of seconds
    self.syncSecondsRemaining -= 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString * identifier = cell.accessibilityIdentifier;
    if(!identifier) {
        NSLog(@"Couldn't determine view controller to show!");
        return;
    }
    UIViewController * viewController = [self.storyboard instantiateViewControllerWithIdentifier: identifier];
    if(viewController) {
        if(UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController: viewController];
            viewController.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
            [self.splitViewController showDetailViewController:navigationController sender:self];
            
        } else {
            [self.navigationController pushViewController:viewController animated:true];
        }
    } else {
        NSLog(@"Couldn't find view controller to show!");
        return;
    }
}

@end
