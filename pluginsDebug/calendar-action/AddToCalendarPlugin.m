/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "AddToCalendarPlugin.h"
@implementation AddToCalendarPlugin

+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

+(void)registerPlugin {
    MCEActionRegistry * registry = [MCEActionRegistry sharedInstance];
    [registry registerTarget: [self sharedInstance] withSelector:@selector(performAction:) forAction: @"calendar"];
}

-(EKEvent*) generateEvent: (NSDictionary*)action store: (EKEventStore *)store {
    EKEvent * event = [EKEvent eventWithEventStore: store];
    event.calendar=store.defaultCalendarForNewEvents;
    
    if(action[@"value"][@"title"]) {
        event.title=action[@"value"][@"title"];
    } else {
        NSLog(@"No title, could not add to calendar");
        return nil;
    }
    
    if(action[@"value"][@"timeZone"]) {
        event.timeZone=[NSTimeZone timeZoneWithAbbreviation: action[@"value"][@"timeZone"]];
    }
    
    if(action[@"value"][@"startDate"]) {
        event.startDate = [MCEApiUtil iso8601ToDate: action[@"value"][@"startDate"]];
    } else {
        NSLog(@"No startDate, could not add to calendar");
        return nil;
    }
    
    if(action[@"value"][@"endDate"]) {
        event.endDate = [MCEApiUtil iso8601ToDate: action[@"value"][@"endDate"]];
    } else {
        NSLog(@"No endDate, could not add to calendar");
        return nil;
    }
    
    if(action[@"value"][@"description"]) {
        event.notes=action[@"value"][@"description"];
    }
    
    return event;
}

-(void)interactivelyAddEvent: (EKEvent*)event store: (EKEventStore*)store {
    EKEventEditViewController *controller = [[EKEventEditViewController alloc] init];
    controller.event = event;
    controller.eventStore = store;
    controller.editViewDelegate = self;
    
    UIViewController * vc = MCESdk.sharedInstance.findCurrentViewController;
    [vc presentViewController:controller animated:TRUE completion:nil];
}

-(void) addEvent: (EKEvent*)event store: (EKEventStore*)store {
    NSError * saveError = nil;
    BOOL success = [store saveEvent: event span:EKSpanThisEvent commit:TRUE error:&saveError];
    if(saveError) {
        NSLog(@"Could not save to calendar %@", [saveError localizedDescription]);
    }
    
    if(!success) {
        NSLog(@"Could not save to calendar");
    }
}

-(void)performAction:(NSDictionary*)action {
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if(error) {
            NSLog(@"Could not add to calendar %@", [error localizedDescription]);
            return;
        }
        if(!granted) {
            NSLog(@"Could not get access to EventKit, can't add to calendar");
            return;
        }
        
        EKEvent * event = [self generateEvent:action store:store];
        if(event) {
            if([action[@"value"][@"interactive"] boolValue]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self interactivelyAddEvent: event store:store];
                });
            } else {
                [self addEvent:event store:store];
            }
        }
    }];
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    switch (action) {
        case  EKEventEditViewActionCanceled:
            NSLog(@"Event was not added to calendar");
            break;
        case EKEventEditViewActionSaved:
            NSLog(@"Event was added to calendar");
            break;
        case EKEventEditViewActionDeleted:
            NSLog(@"Event was deleted from calendar");
            break;
            
        default:
            break;
    }
    UIViewController * vc = MCESdk.sharedInstance.findCurrentViewController;
    [vc dismissViewControllerAnimated:YES completion:nil];
}

@end
