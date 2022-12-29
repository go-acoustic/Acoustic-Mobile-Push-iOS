/*
 * Copyright © 2014, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "DisplayWebViewPlugin.h"
#import "WebViewController.h"

@implementation DisplayWebViewPlugin

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)performAction:(NSDictionary*)action
{
    WebViewController * viewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil url: [NSURL URLWithString:action[@"value"][@"url"]]];
    
    UIViewController * controller = MCESdk.sharedInstance.findCurrentViewController;
    if(controller) {
        [controller presentViewController:viewController animated:TRUE completion:nil];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self performAction:action];
        });
    }
}

+(void)registerPlugin
{
    MCEActionRegistry * registry = [MCEActionRegistry sharedInstance];
    [registry registerTarget: [self sharedInstance] withSelector:@selector(performAction:) forAction: @"displayWebView"];
}

@end
