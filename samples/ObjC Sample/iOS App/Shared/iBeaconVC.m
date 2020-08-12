/*
 * Copyright © 2016, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "iBeaconVC.h"
#import "UIColor+Sample.h"

#if __has_feature(modules)
@import AcousticMobilePush;
#else
#import <AcousticMobilePush/AcousticMobilePush.h>
#endif

@interface iBeaconVC ()
@property NSArray * beaconRegions;
@property NSMutableDictionary * beaconStatus;
@property CLLocationManager * locationManager;
@end

@implementation iBeaconVC

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // iOS 13 Multiple Window Support
    if(@available(iOS 13.0, *)) {
        self.view.window.windowScene.userActivity = [[NSUserActivity alloc] initWithActivityType:@"co.acoustic.mobilepush"];
        self.view.window.windowScene.userActivity.title = NSStringFromClass(self.class);
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // iOS 13 Multiple Window Support
    if(@available(iOS 13.0, *)) {
        self.view.window.windowScene.userActivity = nil;
    }
}

-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
    });
    
    self.beaconRegions = [[[MCELocationDatabase sharedInstance] beaconRegions] sortedArrayUsingDescriptors: @[[NSSortDescriptor sortDescriptorWithKey: @"major" ascending: TRUE]]];
    self.beaconStatus = [NSMutableDictionary dictionary];
    [[NSNotificationCenter defaultCenter] addObserverForName:EnteredBeacon object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        self.beaconStatus[note.userInfo[@"major"]] = [NSString stringWithFormat: @"Entered Minor %@", note.userInfo[@"minor"]];
        [self.tableView reloadData];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:ExitedBeacon object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        self.beaconStatus[note.userInfo[@"major"]] = [NSString stringWithFormat: @"Exited Minor %@", note.userInfo[@"minor"]];
        [self.tableView reloadData];
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:LocationDatabaseUpdated object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        self.beaconRegions = [[[MCELocationDatabase sharedInstance] beaconRegions] sortedArrayUsingDescriptors: @[[NSSortDescriptor sortDescriptorWithKey: @"major" ascending: TRUE]]];
        [self.tableView reloadData];
    }];
}

-(IBAction)refresh:(id)sender
{
    [[[MCELocationClient alloc] init] scheduleSync];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && indexPath.item == 1)
    {
        [MCESdk.sharedInstance manualLocationInitialization];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        UITableViewCell * vertical = [tableView dequeueReusableCellWithIdentifier:@"vertical" forIndexPath:indexPath];
        MCEConfig* config = [[MCESdk sharedInstance] config];
        
        if(indexPath.item==0)
        {
            vertical.textLabel.text = @"UUID";
            NSString * uuid = [config.beaconUUID UUIDString];
            if(uuid)
            {
                vertical.detailTextLabel.text = uuid;
                vertical.detailTextLabel.textColor=UIColor.successColor;
            }
            else
            {
                vertical.detailTextLabel.text = @"UNDEFINED";
                vertical.detailTextLabel.textColor=UIColor.disabledColor;
            }
        }
        else
        {
            vertical.textLabel.text = @"Status";
            if(config.beaconEnabled)
            {
                switch(CLLocationManager.authorizationStatus)
                {
                    case kCLAuthorizationStatusDenied:
                        vertical.detailTextLabel.text = @"DENIED";
                        vertical.detailTextLabel.textColor = [UIColor failureColor];
                        break;
                    case kCLAuthorizationStatusNotDetermined:
                        vertical.detailTextLabel.text = @"DELAYED (Touch to enable)";
                        vertical.detailTextLabel.textColor = [UIColor disabledColor];

                        break;
                    case kCLAuthorizationStatusAuthorizedAlways:
                        vertical.detailTextLabel.text = @"ENABLED";
                        vertical.detailTextLabel.textColor=[UIColor successColor];
                        break;
                    case kCLAuthorizationStatusAuthorizedWhenInUse:
                        vertical.detailTextLabel.text = @"ENABLED WHEN IN USE";
                        vertical.detailTextLabel.textColor=[UIColor disabledColor];
                        break;
                    case kCLAuthorizationStatusRestricted:
                        vertical.detailTextLabel.text = @"RESTRICTED?";
                        vertical.detailTextLabel.textColor = [UIColor disabledColor];
                        break;
                }
            }
            else
            {
                vertical.detailTextLabel.text = @"DISABLED";
                vertical.detailTextLabel.textColor=[UIColor failureColor];
            }
        }
        return vertical;
    }

    UITableViewCell * basic = [tableView dequeueReusableCellWithIdentifier:@"basic" forIndexPath:indexPath];

    NSNumber * major = [self.beaconRegions[indexPath.item] major];
    basic.textLabel.text = [NSString stringWithFormat: @"%@", major];
    if(self.beaconStatus[major])
        basic.detailTextLabel.text = self.beaconStatus[major];
    else
        basic.detailTextLabel.text = @"";

    return basic;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0)
        return 2;
    return self.beaconRegions.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section==0)
        return @"iBeacon Feature";
    return @"iBeacon Major Regions";
}
@end
