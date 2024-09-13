/*
 * Copyright © 2016, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "TextInputActionPlugin.h"

@implementation TextInputActionPlugin

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

//* Implementing this method lets the SDK know you want an alert to ask for the textInput when it doesn't come through the system.
-(void) configureAlertTextField: (UITextField *) textField
{
    
}
//*/

-(void)performAction:(NSDictionary*)action withPayload:(NSDictionary*)payload textInput:(NSString*)textInput
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle: [NSString stringWithFormat: @"User entered text %@", textInput] message:nil preferredStyle: UIAlertControllerStyleAlert];
    [alert addAction: [UIAlertAction actionWithTitle:@"Ok" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    UIViewController * controller = MCESdk.sharedInstance.findCurrentViewController;
    [controller presentViewController:alert animated:TRUE completion:^{}];
}

+(void)registerPlugin
{
    MCEActionRegistry * registry = [MCEActionRegistry sharedInstance];
    [registry registerTarget: [self sharedInstance] withSelector:@selector(performAction:withPayload:textInput:) forAction: @"textInput"];
}

@end
