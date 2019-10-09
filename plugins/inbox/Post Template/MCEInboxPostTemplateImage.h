/*
 * Copyright © 2016, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#if __has_feature(modules)
@import UIKit;
@import AcousticMobilePush;
#else
#import <UIKit/UIKit.h>
#import <AcousticMobilePush/AcousticMobilePush.h>
#endif

@interface MCEInboxPostTemplateImage : UIViewController

@property IBOutlet UIImageView * contentView;
@property IBOutlet UIView * imagesView;
@property IBOutlet UIActivityIndicatorView * spinner;

@property dispatch_queue_t queue;

-(IBAction)dismiss: (id)sender;
-(BOOL)isBlurAvailable;
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil imageUrlString: (NSString*)imageUrlString;

@end
