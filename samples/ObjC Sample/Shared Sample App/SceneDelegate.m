/*
* Copyright © 2019 Acoustic, L.P. All rights reserved.
*
* NOTICE: This file contains material that is confidential and proprietary to
* Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
* industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
* Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
* prohibited.
*/

#import "SceneDelegate.h"
#import "MCEInboxTableViewController.h"
#import "MainVC.h"
#import "StateController.h"

@import AcousticMobilePush;

@implementation SceneDelegate

-(void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions API_AVAILABLE(ios(13.0)) {
    if(![scene isKindOfClass: UIWindowScene.class]) {
        return;
    }

    UIWindowScene * windowScene = (UIWindowScene*) scene;

    if(!self.window) {
        self.window = [[UIWindow alloc] initWithFrame: windowScene.coordinateSpace.bounds];
    }

    self.window.windowScene = windowScene;
    [StateController assembleWindow: self.window];
    
    NSUserActivity * userActivity = session.scene.userActivity;
    if(!userActivity) {
        userActivity = session.stateRestorationActivity;
    }
    
    if(userActivity) {
        [StateController restoreState:userActivity.userInfo toWindow:self.window];
    } else {
        userActivity = [[NSUserActivity alloc] initWithActivityType:@"co.acoustic.mobilepush"];
    }
    
    scene.userActivity = userActivity;
    
    UIOpenURLContext * urlContext = connectionOptions.URLContexts.anyObject;
    if(urlContext) {
        NSURL * url = urlContext.URL;
        if(url) {
            NSLog(@"URL delivered to scene:willConnectToSession:options:");
            [self displayCustomUrl: url];
        }
    }
}

-(void)displayCustomUrl:(NSURL*)url {
    UIAlertController * controller = [UIAlertController alertControllerWithTitle:@"Custom URL Clicked" message:url.absoluteString preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction: [UIAlertAction actionWithTitle:@"Okay" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [controller dismissViewControllerAnimated:TRUE completion:^{
            
        }];
    }]];
    [self.window.rootViewController presentViewController:controller animated:true completion:^{
        
    }];
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts API_AVAILABLE(ios(13.0)){
    UIOpenURLContext * urlContext = URLContexts.anyObject;
    if(urlContext) {
        NSURL * url = urlContext.URL;
        if(url) {
            NSLog(@"URL delivered to scene:willConnectToSession:options:");
            [self displayCustomUrl: url];
        }
    }

}

-(NSUserActivity *)stateRestorationActivityForScene:(UIScene *)scene API_AVAILABLE(ios(13.0)) {
    if(![scene isKindOfClass: UIWindowScene.class]) {
        return nil;
    }
            
    if(!scene.userActivity) {
        scene.userActivity = [[NSUserActivity alloc] initWithActivityType:@"co.acoustic.mobilepush"];
    }
    
    scene.userActivity.userInfo = [StateController stateForWindow: self.window];
    return scene.userActivity;
}

@end
