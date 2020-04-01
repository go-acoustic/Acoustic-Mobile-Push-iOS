/*
 * Copyright © 2015, 2020 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#if __has_feature(modules)
@import Foundation;
@import AcousticMobilePush;
#else
#import <Foundation/Foundation.h>
#import <AcousticMobilePush/AcousticMobilePush.h>
#endif

#import "MCEInboxActionPlugin.h"

@interface MCEInboxActionPlugin  ()
@property NSString * attribution;
@property NSNumber * mailingId;
@property UIViewController <MCETemplateDisplay> * displayViewController;
@end

@implementation MCEInboxActionPlugin

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)displayRichContent: (MCEInboxMessage*)inboxMessage
{
    inboxMessage.isRead = TRUE;
    [[MCEEventService sharedInstance] recordViewForInboxMessage:inboxMessage attribution: self.attribution mailingId: self.mailingId];
    
    self.displayViewController.inboxMessage = inboxMessage;
    [self.displayViewController setContent];
}

-(void)showInboxMessage:(NSDictionary*)action payload:(NSDictionary*)payload
{
    self.attribution=nil;
    self.mailingId=nil;
    if(payload[@"mce"])
    {
        self.attribution = payload[@"mce"][@"attribution"];
        if([payload[@"mce"][@"mailingId"] respondsToSelector:@selector(isEqualToNumber:)]) {
            self.mailingId = payload[@"mce"][@"mailingId"];
        } else if ([payload[@"mce"][@"mailingId"] respondsToSelector:@selector(isEqualToString:)]) {
            NSString * string = payload[@"mce"][@"mailingId"];
            double value = [string doubleValue];
            self.mailingId = @(value);
        }
    }
    
    if(!action[@"inboxMessageId"])
    {
        NSLog(@"Could not showInboxMessage, no inboxMessageId included %@", action);
        return;
    }
    
    MCEInboxMessage * inboxMessage = [[MCEInboxDatabase sharedInstance] inboxMessageWithInboxMessageId: action[@"inboxMessageId"]];
    if(inboxMessage) {
        [self showInboxMessage: inboxMessage];
    } else {
        [MCEInboxQueueManager.sharedInstance getInboxMessageId:action[@"inboxMessageId"] completion:^(MCEInboxMessage *inboxMessage, NSError *error) {
            if(error) {
                NSLog(@"Could not get inbox message from database %@", error);
                return;
            }
            [self showInboxMessage: inboxMessage];
        }];
    }
}

-(void)showInboxMessage: (MCEInboxMessage *)inboxMessage
{
    if(![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(showInboxMessage:) withObject:inboxMessage waitUntilDone:NO];
        return;
    }
    
    self.displayViewController = (UIViewController<MCETemplateDisplay> *) [[MCETemplateRegistry sharedInstance] viewControllerForTemplate: inboxMessage.templateName];
    
    if(!self.displayViewController) {
        NSLog(@"Could not showInboxMessage, %@ template not registered", inboxMessage.templateName);
        return;
    }
    
    [self.displayViewController setLoading];
    UIViewController * controller = MCESdk.sharedInstance.findCurrentViewController;
    [controller presentViewController:(UIViewController*)self.displayViewController animated:TRUE completion:nil];
    [self displayRichContent: inboxMessage];
}

+(void)registerPlugin
{
    [MCEActionRegistry.sharedInstance registerTarget: [self sharedInstance] withSelector:@selector(showInboxMessage:payload:) forAction: @"openInboxMessage"];
}

@end
