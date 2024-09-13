/*
 * Copyright © 2014, 2019 Acoustic, L.P. All rights reserved.
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

@interface MCEInAppBannerTemplate : UIViewController <MCEInAppTemplate>
@property IBOutlet NSLayoutConstraint * topConstraint;
@property IBOutlet NSLayoutConstraint * bottomConstraint;
@property IBOutlet UILabel * label;
@property IBOutlet UIImageView * icon;
@property IBOutlet UIImageView * close;
-(IBAction)dismiss:(id)sender;
-(IBAction)tap:(id)sender;
-(IBAction)dismissLeft:(id)sender;
-(IBAction)dismissRight:(id)sender;
@end
