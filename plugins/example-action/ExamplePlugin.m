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
@import AcousticMobilePush;
#else
#import <AcousticMobilePush/AcousticMobilePush.h>
#endif

#import "ExamplePlugin.h"
#import "ExampleViewController.h"

@implementation ExamplePlugin

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)performAction:(NSDictionary*)payload
{
    //get the dictionary which contains the custom properties defined in the action
    NSDictionary *customProperties = [payload objectForKey:@"value"];
    
    if (customProperties) {
        //Get custom properties. These properties correspond to the ones created in the action
        NSNumber *openForActionValue = [customProperties objectForKey:@"openForAction"];
        NSNumber *sendEventValue = [customProperties objectForKey:@"sendCustomEvent"];
        //send custom metric to server
        if ([sendEventValue boolValue]) {
            MCEEvent * event = [[MCEEvent alloc] init];
            //name and attributes must be updated, but type needs to be custom since we are sending a custom event
            [event fromDictionary:@{ @"name":@"examplePluginActionTaken", @"type":@"custom", @"timestamp":[NSDate date], @"attributes":@{@"customData1":openForActionValue, @"customData2":sendEventValue}}];
            [[MCEEventService sharedInstance] addEvent: event immediate: FALSE];
        }
        //send payload to screen
        if ([openForActionValue boolValue]) {
            ExampleViewController * viewController = [[ExampleViewController alloc] initWithNibName:@"ExampleViewController" bundle:nil payload: payload];
            UIViewController * controller = MCESdk.sharedInstance.findCurrentViewController;
            [controller presentViewController:viewController animated:TRUE completion:nil];
        }
        //send payload to log
        else {
            NSLog(@"Payload is:%@", payload);
        }
    }
}

+(void)registerPlugin
{
    MCEActionRegistry * registry = [MCEActionRegistry sharedInstance];
    [registry registerTarget: [self sharedInstance] withSelector:@selector(performAction:) forAction: @"example"];
}

@end
