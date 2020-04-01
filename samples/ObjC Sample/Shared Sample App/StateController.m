/*
* Copyright © 2020, 2020 Acoustic, L.P. All rights reserved.
*
* NOTICE: This file contains material that is confidential and proprietary to
* Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
* industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
* Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
* prohibited.
*/ 

#import "StateController.h"
#import "MCEInboxTableViewController.h"
#import "MainVC.h"
#import "NavigationController.h"
#import "RegistrationVC.h"
#import <AcousticMobilePush/AcousticMobilePush.h>

@implementation StateController

+(NSString*)appVersion {
    return NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
}

+(void)assembleWindow:(UIWindow*) window {
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    MainVC * mainViewController = [storyBoard instantiateViewControllerWithIdentifier:@"Main"];
    NavigationController * masterViewController = [[NavigationController alloc] initWithRootViewController: mainViewController];
    
    if(UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UISplitViewController * splitViewController = [[UISplitViewController alloc] init];
        RegistrationVC * registrationVC = [storyBoard instantiateViewControllerWithIdentifier:@"Registration"];
        NavigationController * detailViewController = [[NavigationController alloc] initWithRootViewController: registrationVC];
        splitViewController.viewControllers = @[masterViewController, detailViewController];
        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem;
        window.rootViewController = splitViewController;
    } else {
        window.rootViewController = masterViewController;
    }
    [window makeKeyAndVisible];
}

+(NSDictionary *) stateForWindow: (UIWindow*)window {
    NSMutableDictionary * state = [NSMutableDictionary dictionary];
    
    NSString * appVersion = self.appVersion;
    if(!appVersion) {
        return nil;
    }
    state[@"AppVersion"] = appVersion;

    UINavigationController * navigationController = [self findNavigationControllerInWindow: window];
    if(!navigationController){
        return nil;
    }
    
    
    UIViewController * visibleViewController = [navigationController visibleViewController];
    NSString * interface = NSStringFromClass(visibleViewController.class);
    if(!interface) {
        return nil;
    }
    state[@"interface"] = interface;
    
    if([visibleViewController respondsToSelector: @selector(interfaceState)]) {
        UIViewController<RestorableVC> * restorableViewController = (UIViewController<RestorableVC> *) visibleViewController;
        NSData * interfaceState = [restorableViewController interfaceState];
        if(interfaceState) {
            state[@"interfaceState"] = interfaceState;
        }
    }

    if([visibleViewController respondsToSelector:@selector(inboxMessage)]) {
        UIViewController<MCETemplateDisplay> * inboxViewController = (UIViewController<MCETemplateDisplay> *) visibleViewController;
        MCEInboxMessage * inboxMessage = [inboxViewController inboxMessage];
        state[@"inboxMessageId"] = inboxMessage.inboxMessageId;
    }

    return state;
}

+(UINavigationController*)findNavigationControllerInWindow: (UIWindow*)window {
    UINavigationController * navigationController = nil;
    UIViewController * rootViewController = window.rootViewController;
    if([rootViewController isKindOfClass: UISplitViewController.class]) {
        UISplitViewController * splitViewController = (UISplitViewController *)rootViewController;
        navigationController = (UINavigationController*) splitViewController.viewControllers.lastObject;
    } else if([rootViewController isKindOfClass: UINavigationController.class]) {
        navigationController = (UINavigationController*) rootViewController;
    }

    if(![navigationController isKindOfClass:UINavigationController.class]) {
        return nil;
    }
    
    return navigationController;
}

+(void)restoreState: (NSDictionary*)state toWindow:(UIWindow*) window {
    if(!state) {
        return;
    }
    
    NSString * interface = state[@"interface"];
    if(!interface) {
        return;
    }
    
    NSDictionary * classToIdentifier = @{
        @"MainVC": @"Main",
        @"AttributesVC": @"Attributes",
        @"CustomActionVC": @"CustomAction",
        @"EventVC": @"Events",
        @"GeofenceVC": @"Geofences",
        @"iBeaconVC": @"iBeacons",
        @"InAppVC": @"In App",
        @"RegistrationVC": @"Registration",
        @"MCEInboxTableViewController": @"Inbox"
    };
    
    NSString * identifier = classToIdentifier[interface];
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    NSMutableArray * viewControllers = [NSMutableArray array];
    NSString * inboxMessageId = state[@"inboxMessageId"];
    UIViewController * viewController = nil;
    if(identifier) {
        viewController = [storyboard instantiateViewControllerWithIdentifier:identifier];
    } else if(inboxMessageId) {
        MCEInboxMessage * inboxMessage = [MCEInboxDatabase.sharedInstance inboxMessageWithInboxMessageId:inboxMessageId];
        if(inboxMessage) {
            MCEInboxTableViewController * inboxViewController = [storyboard instantiateViewControllerWithIdentifier:@"Inbox"];
            [viewControllers addObject:inboxViewController];
            
            if(inboxViewController && [inboxViewController isKindOfClass:MCEInboxTableViewController.class] && inboxMessage && [inboxMessage isKindOfClass:MCEInboxMessage.class]) {
                viewController = [inboxViewController viewControllerForInboxMessage:inboxMessage];
            }
        }
    } else {
        viewController = [[NSClassFromString(interface) alloc] init];
    }
    if(!viewController) {
        return;
    }
    
    [viewControllers addObject: viewController];

    UINavigationController * navigationController = [self findNavigationControllerInWindow: window];
    if(!navigationController) {
        return;
    }
    
    if(![interface isEqual: @"MainVC"]) {
        MainVC * mainVC = [storyboard instantiateViewControllerWithIdentifier:@"Main"];
        [viewControllers insertObject:mainVC atIndex:0];
    }

    navigationController.viewControllers = viewControllers;
    
    NSData * interfaceState = state[@"interfaceState"];
    if(interfaceState && [viewController respondsToSelector:@selector(setInterfaceState:)]) {
        UIViewController<RestorableVC> * restoreableViewController = (UIViewController<RestorableVC> *)viewController;
        restoreableViewController.interfaceState = interfaceState;
    }
}

+(BOOL)stateIsRestorable:(NSDictionary*)state {
    NSString * appVersion = self.appVersion;
    if(!appVersion) {
        return false;
    }
    NSString * version = state[@"AppVersion"];
    if(![appVersion isEqual: version]) {
        return false;
    }
    
    NSString * interface = state[@"interface"];
    if(!interface) {
        return false;
    }
    
    return true;
}

@end
