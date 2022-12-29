/*
 * Copyright © 2011, 2020 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#if __has_feature(modules)
@import UserNotifications;
@import MessageUI;
@import AcousticMobilePush;
#else
#import <UserNotifications/UserNotifications.h>
#import <AcousticMobilePush/AcousticMobilePush.h>
#import <MessageUI/MessageUI.h>
#endif

#import "StateController.h"
#import "AppDelegate.h"
#import "MailDelegate.h"
#import "NavigationController.h"


// Action Plugins
#import "ActionMenuPlugin.h"
#import "AddToCalendarPlugin.h"
#import "AddToWalletPlugin.h"
#import "SnoozeActionPlugin.h"
#import "DisplayWebViewPlugin.h"
#import "TextInputActionPlugin.h"
#import "ExamplePlugin.h"
#import "CarouselAction.h"

// MCE Inbox Plugins
#import "MCEInboxActionPlugin.h"
#import "MCEInboxPostTemplate.h"
#import "MCEInboxDefaultTemplate.h"

// MCE InApp Plugins
#import "MCEInAppVideoTemplate.h"
#import "MCEInAppImageTemplate.h"
#import "MCEInAppBannerTemplate.h"

#import "RegistrationVC.h"
#import "MainVC.h"

#ifdef MANUAL
#import "Config.h"
#import "NotificationDelegate.h"
#endif

// This class is completely optional, it's only needed if you require alert message customizations
@interface MyAlertController : UIAlertController

@end

@implementation MyAlertController
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    NSLog(@"Do customizations here or replace with a duck typed class");
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}
@end

@interface AppDelegate ()
@property NSDictionary * state;
@end

@implementation AppDelegate

#ifdef MANUAL
-(void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"deviceToken: %@", [MCEApiUtil deviceToken: deviceToken]);
    [[MCESdk sharedInstance]registerDeviceToken:deviceToken];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError %@", [error localizedDescription]);
    [[MCESdk sharedInstance]deviceTokenRegistartionFailed];
}
#endif


// This method updates the badge count when the number of unread messages changes.
// If you have additional user messages that should be reflected, that can be done here.
-(void)inboxUpdate {
    int unreadCount = [[MCEInboxDatabase sharedInstance] unreadMessageCount];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication.sharedApplication setApplicationIconBadgeNumber: unreadCount];
    });
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSLog(@"URL delivered to application:openURL:options:");
    UIAlertController * controller = [UIAlertController alertControllerWithTitle:@"Custom URL Clicked" message:url.absoluteString preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction: [UIAlertAction actionWithTitle:@"Okay" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [controller dismissViewControllerAnimated:TRUE completion:^{
            
        }];
    }]];
    [self.window.rootViewController presentViewController:controller animated:true completion:^{
        
    }];
    
    return true;
}

-(void)registerPlugins {
    // MCE Inbox plugins
    [MCEInboxActionPlugin registerPlugin];
    [MCEInboxPostTemplate registerTemplate];
    [MCEInboxDefaultTemplate registerTemplate];
    
    // MCE InApp Plugins
    [MCEInAppVideoTemplate registerTemplate];
    [MCEInAppImageTemplate registerTemplate];
    [MCEInAppBannerTemplate registerTemplate];
    
    // Action Plugins
    [ActionMenuPlugin registerPlugin];
    [ExamplePlugin registerPlugin];
    [AddToCalendarPlugin registerPlugin];
    [AddToWalletPlugin registerPlugin];
    [SnoozeActionPlugin registerPlugin];
    [DisplayWebViewPlugin registerPlugin];
    [TextInputActionPlugin registerPlugin];
    [CarouselAction registerPlugin];
    
    // Custom Send Email Plugin Example
    [[MCEActionRegistry sharedInstance] registerTarget:[[MailDelegate alloc] init] withSelector:@selector(sendEmail:) forAction:@"sendEmail"];
}

-(void)overridePresentNotifications {
    MCESdk.sharedInstance.presentNotification = ^BOOL(NSDictionary * userInfo){
        NSLog(@"Checking if should present notification!");
        
        // return FALSE if you don't want the notification to show to the user when the app is active
        return TRUE;
    };
}

// Completely Optional
-(void)overrideAlertControllerClass {
    [MCESdk sharedInstance].customAlertControllerClass = [MyAlertController class];
}

// Completely Optional
-(void)initializeUserIfInvalidated {
    if(MCERegistrationDetails.sharedInstance.userInvalidated) {
        [MCESdk.sharedInstance manualInitialization];
    }
}

// iOS 10+ Example static action category: (Completely optional)
-(NSSet*) applicationCategories {
    UNNotificationAction * acceptAction = [UNNotificationAction actionWithIdentifier:@"Accept" title:@"Accept" options:UNNotificationActionOptionForeground];
    UNNotificationAction * fooAction = [UNNotificationAction actionWithIdentifier:@"Foo" title:@"Foo" options:UNNotificationActionOptionForeground];
    UNNotificationAction * rejectAction = [UNNotificationAction actionWithIdentifier:@"Reject" title:@"Reject" options:UNNotificationActionOptionDestructive];
    UNNotificationCategory * category = [UNNotificationCategory categoryWithIdentifier:@"example" actions:@[acceptAction, fooAction, rejectAction] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
    return [NSSet setWithObject: category];
}

// Required
-(void)requestUserNotifications {
    NSUInteger options = 0;
    if(@available(iOS 12.0, *)) {
        options = UNAuthorizationOptionAlert|UNAuthorizationOptionSound|UNAuthorizationOptionBadge|UNAuthorizationOptionCarPlay|UNAuthorizationOptionProvidesAppNotificationSettings;
    } else {
        options = UNAuthorizationOptionAlert|UNAuthorizationOptionSound|UNAuthorizationOptionBadge|UNAuthorizationOptionCarPlay;
    }

    UNUserNotificationCenter * center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions: options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
        // This isn't required, it's here to demonstrate how to register static category actions
        [center setNotificationCategories: [self applicationCategories]];
    }];
}

// Completely Optional
-(void)registerPushSettingsSelectionScreen {
    if(@available(iOS 12.0, *)) {
        MCESdk.sharedInstance.openSettingsForNotification = ^(UNNotification *notification) {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Should show app settings for notifications" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction: [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [[MCESdk.sharedInstance findCurrentViewController] presentViewController:alert animated:true completion: ^{
                
            }];
        };
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    #ifdef MANUAL
    [MCESdk.sharedInstance handleApplicationLaunchWithConfig: Config.mobilePushConfig];
    UNUserNotificationCenter.currentNotificationCenter.delegate = NotificationDelegate.sharedInstance;
    #endif
    
    [self registerPlugins];
    [self overridePresentNotifications];
    [self overrideAlertControllerClass];
    [self initializeUserIfInvalidated];
    
    [application registerForRemoteNotifications];
    [self requestUserNotifications];
    
    [self registerPushSettingsSelectionScreen];
    [self inboxUpdate];
    
    // Sample App Specific
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inboxUpdate) name: InboxCountUpdate object:nil];

    // Sample App Specific
    [[NSUserDefaults standardUserDefaults]registerDefaults:@{@"action":@"update",@"standardType":@"dial", @"standardDialValue":@"\"8774266006\"", @"standardUrlValue":@"\"http://acoustic.co\"", @"customType":@"sendEmail", @"customValue":@"{\"subject\":\"Hello from Sample App\", \"body\": \"This is an example email body\", \"recipient\":\"fake-email@fake-site.com\"}", @"categoryId":@"example",@"button1":@"Accept",@"button2":@"Reject"}];
    
    self.window = [[UIWindow alloc] initWithFrame: UIScreen.mainScreen.bounds];
    [StateController assembleWindow: self.window];
    [StateController restoreState: self.state toWindow:self.window];
    return YES;
}

// Silent Notification "content-available"
// Completely optional
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    completionHandler(UIBackgroundFetchResultNewData);
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
    NSDictionary * state = [StateController stateForWindow: self.window];
    if(state) {
        [coder encodeObject: state forKey:@"state"];
        return true;
    }
    return false;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
    NSDictionary * state = [coder decodeObjectForKey:@"state"];
    if([StateController stateIsRestorable: state]) {
        self.state = state;
        return true;
    }
    
    return false;
}

@end
