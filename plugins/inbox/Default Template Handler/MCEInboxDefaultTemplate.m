/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */


#import <objc/runtime.h>

#if __has_feature(modules)
@import AcousticMobilePush;
#else
#import <AcousticMobilePush/AcousticMobilePush.h>
#endif

#import "MCEInboxDefaultTemplate.h"
#import "MCEInboxDefaultTemplateCell.h"
#import "MCEInboxDefaultTemplateDisplay.h"

@implementation MCEInboxDefaultTemplate

-(BOOL)shouldDisplayInboxMessage: (MCEInboxMessage*)inboxMessage
{
    /* This would not allow the inbox to open messages that are expired */
    //if([inboxMessage isExpired])
    //    return FALSE;
    return TRUE;
}

/* This method is used to register this template with the template registry system so we can display default template messages */
+(void)registerTemplate
{
    [[MCETemplateRegistry sharedInstance] registerTemplate:@"default" handler:[[self alloc]init]];
}

/* This method will give the inbox system a view controller to display full messages in. */
-(id<MCETemplateDisplay>)displayViewController
{
    return [[MCEInboxDefaultTemplateDisplay alloc] initWithNibName:@"MCEInboxDefaultTemplateDisplay" bundle:nil];
}

/* This method provides a blank table view cell that can later be customized to preview the message */
-(UITableViewCell *) cellForTableView: (UITableView*)tableView inboxMessage:(MCEInboxMessage *)inboxMessage indexPath:(NSIndexPath*)indexPath
{
    NSString * identifier = @"defaultTemplateCell";
    MCEInboxDefaultTemplateCell * cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if(!cell)
    {
        NSLog(@"Creating a new cell!");
        UINib * nib = [UINib nibWithNibName:@"MCEInboxDefaultTemplateCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier: identifier];
        cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    }
    [cell setInboxMessage:inboxMessage];
    return cell;
}

/* This method lets the table view displaying previews know how high cells will be. */
-(float)tableView: (UITableView*)tableView heightForRowAtIndexPath: (NSIndexPath*)indexPath inboxMessage: (MCEInboxMessage*)message
{
    return 50;
}

@end
