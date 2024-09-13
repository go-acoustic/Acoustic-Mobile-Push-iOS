/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "MCEInboxPostTemplateImage.h"

@interface MCEInboxPostTemplateImage ()
@property NSString * imageUrlString;
@end

@implementation MCEInboxPostTemplateImage

-(IBAction)dismiss: (id)sender
{
    [self dismissViewControllerAnimated:TRUE completion:^{
    }];
}

-(BOOL)shouldAutorotate
{
    return true;
}

-(BOOL)isBlurAvailable
{
    if(!NSClassFromString(@"UIBlurEffect"))
    {
        return FALSE;
    }
    
    if (UIAccessibilityIsReduceTransparencyEnabled())
    {
        return FALSE;
    }
    
    return true;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    NSURL * url = [NSURL URLWithString:self.imageUrlString];
    NSData * imageData = [MCEApiUtil cachedDataForUrl: url downloadIfRequired: FALSE];
    if(imageData)
    {
        UIImage * image = [UIImage imageWithData:imageData];
        self.contentView.image = image;
        [self.spinner stopAnimating];
    }
    else
    {
        [self.spinner startAnimating];
        self.contentView.image = nil;
    }

    if([self isBlurAvailable])
    {
        self.view.backgroundColor=[UIColor clearColor];
        
        // Blur effect
        UIBlurEffect * blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView * visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.translatesAutoresizingMaskIntoConstraints=NO;
        
        [self.view addSubview:visualEffectView];
        
        [self setContraintsForView: visualEffectView];
        
        // Vibrancy effect
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        UIVisualEffectView * vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        vibrancyEffectView.translatesAutoresizingMaskIntoConstraints=NO;
        [visualEffectView.contentView addSubview:vibrancyEffectView];
        [self setContraintsForView: vibrancyEffectView];
        
        // Move container view to inside visualEffectView contentView
        [self.contentView removeFromSuperview];
        [visualEffectView.contentView addSubview:self.contentView];
        [self setContraintsForView: self.contentView];

        // Move top imagesView to vibrancyEffectView contentView
        [self.imagesView removeFromSuperview];
        [vibrancyEffectView.contentView addSubview:self.imagesView];
        [self setContraintsForView: self.imagesView];
    }
}

-(void)setContraintsForView:(UIView*)view
{
    [view.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[view]-0-|" options:0 metrics:@{} views:@{@"view":view}]];
    [view.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|" options:0 metrics:@{} views:@{@"view":view}]];

}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil imageUrlString: (NSString*)imageUrlString
{
    if(self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.imageUrlString = imageUrlString;
        self.queue = dispatch_queue_create("background", nil);
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return true;
}

@end
