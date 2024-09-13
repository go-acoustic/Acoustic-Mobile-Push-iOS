/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "MCEInAppMediaTemplate.h"

@interface MCEInAppMediaTemplate ()
@end

@implementation MCEInAppMediaTemplate

-(IBAction)execute: (id)sender; {
    [self dismiss:self];
    [[MCEInAppManager sharedInstance] disable: self.inAppMessage];
    
    NSDictionary * payload = @{@"mce": [NSMutableDictionary dictionary]};
    if(self.inAppMessage.attribution) {
        payload[@"mce"][@"attribution"] = self.inAppMessage.attribution;
    }
    if(self.inAppMessage.mailingId) {
        payload[@"mce"][@"mailingId"] = self.inAppMessage.mailingId;
    }
    
    [MCEActionRegistry.sharedInstance performAction:self.inAppMessage.content[@"action"] forPayload:payload source:InAppSource attributes:nil userText:nil];
}

-(void)setTextHeight {
    CGRect textSize = [self.textLabel.titleLabel textRectForBounds:CGRectMake(0, 0, self.textLabel.frame.size.width, CGFLOAT_MAX) limitedToNumberOfLines: self.textLabel.titleLabel.numberOfLines];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.textHeightConstraint.constant = textSize.size.height;
        self.foreTextHeightConstraint.constant = textSize.size.height;
        [self.containerView layoutIfNeeded];
        [self.foreContainerView layoutIfNeeded];
    }];
}


-(IBAction)expandText:(id)sender {
    self.autoDismiss = false;
    self.textLabel.titleLabel.numberOfLines = self.textLabel.titleLabel.numberOfLines ? 0 : 2;
    self.foreTextLabel.titleLabel.numberOfLines = self.foreTextLabel.titleLabel.numberOfLines ? 0 : 2;
    [self setTextHeight];
}


-(void)autoDismiss: (id)sender {
    if(self.autoDismiss) {
        [self dismiss:sender];
    }
}

-(IBAction)dismiss: (id)sender {
    [self dismissViewControllerAnimated:TRUE completion:^{
        NSLog(@"Dismissed InApp Message");
    }];
}

-(void)displayInAppMessage:(MCEInAppMessage*)message {
    [self.spinner startAnimating];
    self.autoDismiss = true;
    NSLog(@"Preparing InApp Message");
    self.inAppMessage = message;
    
    if(self.view.superview) {
        [self dismiss:self];
        [self performSelector:@selector(displayInAppMessage:) withObject:message afterDelay:0.3];
        return;
    }
    
    [self.titleLabel setTitle:self.inAppMessage.content[@"title"] forState:UIControlStateNormal];
    [self.foreTitleLabel setTitle:self.inAppMessage.content[@"title"] forState:UIControlStateNormal];
    
    [self.textLabel setTitle:self.inAppMessage.content[@"text"] forState:UIControlStateNormal];
    self.textLabel.titleLabel.numberOfLines = 2;
    
    [self.foreTextLabel setTitle:self.inAppMessage.content[@"text"] forState:UIControlStateNormal];
    self.foreTextLabel.titleLabel.numberOfLines = 2;
    
    [self setTextHeight];
    [self showInAppMessage];
}

-(void)showInAppMessage {
    UIViewController * controller = MCESdk.sharedInstance.findCurrentViewController;
    [controller presentViewController:self animated:true completion:^{
        NSLog(@"Displaying InApp Message");
    }];
}

-(BOOL)shouldAutorotate {
    return true;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    self.textLabel.titleLabel.numberOfLines = 2;
    self.titleLabel.titleLabel.numberOfLines = 1;
    
    // Preventing from recording views for canned inApp messages.
    if (self.inAppMessage.attribution != nil) {
        [[MCEEventService sharedInstance] recordViewForInAppMessage:self.inAppMessage attribution:self.inAppMessage.attribution mailingId:self.inAppMessage.mailingId];
    }
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if(self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.queue = dispatch_queue_create("background", nil);
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return true;
}


@end
