/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "ActionMenuPlugin.h"

@implementation ActionMenuPlugin

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)showActionsMenu:(NSDictionary*)actionMenuAction withPayload:(NSDictionary*)payload
{
    if(!payload[@"category-actions"] || ![payload[@"category-actions"] isKindOfClass:[NSArray class]])
    {
        NSLog(@"Did not get the expected data from payload.");
        return;
    }
    
    MCENotificationPayload * notificationPayload = [[MCENotificationPayload alloc] initWithPayload: payload];
    NSString * alert = [notificationPayload extractAlertString];
    NSString * appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: appName message: alert preferredStyle: UIAlertControllerStyleAlert];
    
    int index=0;
    for (NSDictionary * action in payload[@"category-actions"]) {
        [alertController addAction: [UIAlertAction actionWithTitle:action[@"name"] style:UIAlertActionStyleDefault handler:^(UIAlertAction *alertAction) {
            [MCEActionRegistry.sharedInstance performAction:action forPayload:payload source:SimpleNotificationSource attributes:nil userText:nil];
        }]];
        index++;
    }
    
    [alertController addAction: [UIAlertAction actionWithTitle:@"Cancel" style: UIAlertActionStyleCancel handler:^(UIAlertAction *action){
        // just dismiss alert
    }]];
    
    UIViewController * controller = MCESdk.sharedInstance.findCurrentViewController;
    [controller presentViewController:alertController animated:TRUE completion:nil];
}

+(void)registerPlugin
{
    MCEActionRegistry * registry = [MCEActionRegistry sharedInstance];
    
    [registry registerTarget: [self sharedInstance] withSelector:@selector(showActionsMenu:withPayload:) forAction: @"showactions"];
}

@end
