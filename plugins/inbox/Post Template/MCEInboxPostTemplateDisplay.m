/*
 * Copyright © 2016, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "MCEInboxPostTemplateDisplay.h"

@interface MCEInboxPostTemplateDisplay ()

@end

@implementation MCEInboxPostTemplateDisplay

-(void)syncDatabase:(NSNotification*)notification
{
    if(!self.inboxMessage)
    {
        return;
    }
    
    // May need to refresh if payload is out of sync.
    MCEInboxMessage* newInboxMessage = [[MCEInboxDatabase sharedInstance] inboxMessageWithInboxMessageId:self.inboxMessage.inboxMessageId];
    if(!newInboxMessage)
    {
        NSLog(@"Could not fetch inbox message %@", self.inboxMessage.inboxMessageId);
    }
    
    if([newInboxMessage isEqual: self.inboxMessage])
    {
        return;
    }
    
    [self setContent];
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if(self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncDatabase:) name:MCESyncDatabase object:nil];
    }
    return self;
}

- (BOOL)isModal {
    return self.presentingViewController.presentedViewController == self
    || (self.navigationController != nil && self.navigationController.presentingViewController.presentedViewController == self.navigationController)
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}

-(IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:^{
    }];
}

-(void)setContent
{
    self.contentView.fullScreen = TRUE;
    [self.contentView setInboxMessage: self.inboxMessage resizeCallback: ^(CGSize size, NSURL * url, BOOL reload) {
        [MCEInboxPostTemplate.sharedInstance.contentSizeCache setObject:NSStringFromCGSize(size) forKey:url];
    }];
}
-(void)awakeFromNib
{
    [super awakeFromNib];
    self.view.translatesAutoresizingMaskIntoConstraints=NO;
    self.contentView.translatesAutoresizingMaskIntoConstraints=NO;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.inboxMessage)
    {
        [self setContent];
        self.inboxMessage.isRead = TRUE;
    }
    
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    CGFloat statusBarHeight = MIN(statusBarSize.width, statusBarSize.height);
    CGFloat toolbarHeight = self.toolbar.frame.size.height;
    
    // Adjust spacing between toolbar and top when translucent toolbar or when popup
    if([self isModal])
    {
        self.topConstraint.constant = 0;
        self.toolbarHeightConstraint.constant = toolbarHeight + statusBarHeight;
        
        UIWindow * window = UIApplication.sharedApplication.keyWindow;
        if (@available(iOS 11.0, *)) {
            if(window.safeAreaInsets.top > statusBarHeight) {
                self.toolbarHeightConstraint.constant = toolbarHeight + window.safeAreaInsets.top;
            } else {
                self.toolbarHeightConstraint.constant = toolbarHeight + statusBarHeight;
            }
        }
    }
    else if(self.navigationController.navigationBar.translucent)
    {
        self.topConstraint.constant = statusBarHeight + toolbarHeight;
        self.toolbarHeightConstraint.constant = 0;
    }
    else
    {
        self.topConstraint = 0;
        self.toolbarHeightConstraint.constant = 0;
    }

}

-(void)setLoading
{
}

@end
