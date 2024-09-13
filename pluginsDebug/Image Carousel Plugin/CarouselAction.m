/*
 * Copyright © 2018, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "CarouselAction.h"

@implementation CarouselAction

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)performAction:(NSDictionary*)action withPayload:(NSDictionary*)payload {
    NSNumber * selectedNumber = action[@"value"];
    if(!selectedNumber) {
        NSString * message = [NSString stringWithFormat: @"User Clicked Image or Notification"];
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Carousel Plugin" message: message preferredStyle: UIAlertControllerStyleAlert];
        [alertController addAction: [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil]];
        UIViewController * controller = MCESdk.sharedInstance.findCurrentViewController;
        [controller presentViewController:alertController animated:TRUE completion:nil];
        return;
    }
    int selected = [selectedNumber intValue];
    NSDictionary * carousel = payload[@"carousel"];
    if(!carousel || ![carousel isKindOfClass: NSDictionary.class]) {
        NSLog(@"Can't find carousel dictionary.");
        return;
    }

    NSArray * items = carousel[@"items"];
    if(!items || ![items isKindOfClass: NSArray.class]) {
        NSLog(@"Can't find items array.");
        return;
    }
    NSDictionary * item = items[selected];
    if(!item || ![item isKindOfClass:NSDictionary.class]) {
        NSLog(@"Can't find item dictionary.");
        return;
    }
    
    NSString * message = [NSString stringWithFormat: @"User Choose %@", item[@"text"]];
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Carousel Plugin" message: message preferredStyle: UIAlertControllerStyleAlert];
    [alertController addAction: [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil]];
    UIViewController * controller = MCESdk.sharedInstance.findCurrentViewController;
    [controller presentViewController:alertController animated:TRUE completion:nil];
}

+(void)registerPlugin {
    MCEActionRegistry * registry = [MCEActionRegistry sharedInstance];
    [registry registerTarget: [self sharedInstance] withSelector:@selector(performAction:withPayload:) forAction: @"carousel"];
}

@end
