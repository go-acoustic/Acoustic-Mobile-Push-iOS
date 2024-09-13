/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "MCEInAppImageTemplate.h"

@interface MCEInAppImageTemplate ()
@property NSData * data;

// Only used for disabling vibrantancy selectively
@property UIView * foreTextLine;
@property NSTimer * timer;

@end

@implementation MCEInAppImageTemplate

// Used when text is expanded or contracted, hides foreground elements if collapsed. This is due to the vibrant labels not being able to expand over the non vibrant content image.
-(void)setTextHeight
{
    [super setTextHeight];
    [UIView animateWithDuration:0.25 animations:^{
        if(self.textLabel.titleLabel.numberOfLines == 2)
        {
            self.foreTextLabel.alpha = 0.1;
            self.foreTitleLabel.alpha = 0.1;
            self.foreTextLine.alpha = 0.1;
            self.contentView.alpha = 1;
        }
        else
        {
            self.foreTextLabel.alpha = 1;
            self.foreTitleLabel.alpha = 1;
            self.foreTextLine.alpha = 1;
            self.contentView.alpha = 0.5;
        }
        

        [self.foreTextLine layoutIfNeeded];
        [self.textLine layoutIfNeeded];
    }];
}

-(void)displayInAppMessage:(MCEInAppMessage*)message
{
    [super displayInAppMessage:message];

    dispatch_async(self.queue, ^{
        NSURL * url = [NSURL URLWithString:self.inAppMessage.content[@"image"]];
        self.data = [MCEApiUtil cachedDataForUrl:url downloadIfRequired:TRUE];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            
            float duration = 5;
            if(self.inAppMessage.content[@"duration"]) {
                duration = [self.inAppMessage.content[@"duration"] floatValue];
            }
            
            if(duration>0)
                self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(autoDismiss:) userInfo:nil repeats:NO];
            
            UIImage * image = [UIImage imageWithData:self.data];
            if(image.size.width < self.contentView.imageView.frame.size.width && image.size.height < self.contentView.imageView.frame.size.height) {
                self.contentView.imageView.contentMode = UIViewContentModeCenter;
            } else {
                self.contentView.imageView.contentMode = UIViewContentModeScaleAspectFit;
            }
            [self.contentView setImage:image forState:UIControlStateNormal];
        });
    });
    
}

-(IBAction)dismiss: (id)sender {
    [self.timer invalidate];
    self.timer = nil;
    [super dismiss:sender];
}

-(void)showInAppMessage {
    [self.timer invalidate];
    self.timer = nil;
    [super showInAppMessage];
}

-(void)viewDidLoad {
    [super viewDidLoad];

    [self.contentView addTarget:self action:@selector(execute:) forControlEvents:UIControlEventTouchUpInside];
}

+(void) registerTemplate
{
    [[MCEInAppTemplateRegistry sharedInstance] registerTemplate:@"image" handler:[[self alloc] initWithNibName: @"MCEInAppImageTemplate" bundle: nil]];
}


@end
