/*
 * Copyright © 2017, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "NotificationController.h"


@interface NotificationController ()

@end


@implementation NotificationController

- (instancetype)init {
    self = [super init];
    if (self){
        // Initialize variables here.
        // Configure interface objects here.
        
    }
    return self;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

/*
- (void)didReceiveNotification:(UNNotification *)notification withCompletion:(void(^)(WKUserNotificationInterfaceType interface)) completionHandler {
    // This method is called when a notification needs to be presented.
    // Implement it if you use a dynamic notification interface.
    // Populate your dynamic notification interface as quickly as possible.
    //
    // After populating your dynamic notification interface call the completion block.
    completionHandler(WKUserNotificationInterfaceTypeCustom);
}
*/

@end



