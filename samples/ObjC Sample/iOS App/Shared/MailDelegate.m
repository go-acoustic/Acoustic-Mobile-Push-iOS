/*
 * Copyright © 2011, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */
#import "MailDelegate.h"

#if __has_feature(modules)
@import AcousticMobilePush;
#else
#import <AcousticMobilePush/AcousticMobilePush.h>
#endif

@interface MailDelegate ()
@property MFMailComposeViewController * mailController;
@end

@implementation MailDelegate

#pragma mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch(result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail send was canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail was saved as draft");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail was sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail send failed");
            break;
    }
    [controller dismissViewControllerAnimated:TRUE completion:^(){}];
}

#pragma mark Process Custom Action
-(void)sendEmail:(NSDictionary*)action
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        NSLog(@"Custom action with value %@", action[@"value"]);
        
        if(![MFMailComposeViewController canSendMail])
        {
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Cannot send mail" message:@"Please verify that you have a mail account setup." preferredStyle: UIAlertControllerStyleAlert];
            [alert addAction: [UIAlertAction actionWithTitle:@"OK" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }]];
            [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alert animated:true completion:^{}];
            return;
        }

        self.mailController = [[MFMailComposeViewController alloc] init];
        self.mailController.mailComposeDelegate=self;
        [self.mailController setSubject: action[@"value"][@"subject"]];
        [self.mailController setToRecipients: @[action[@"value"][@"recipient"]]];
        [self.mailController setMessageBody:action[@"value"][@"body"] isHTML:FALSE];

        UIViewController * controller = MCESdk.sharedInstance.findCurrentViewController;
        [controller presentViewController:self.mailController animated:TRUE completion:^(void){}];
    });
}

@end
