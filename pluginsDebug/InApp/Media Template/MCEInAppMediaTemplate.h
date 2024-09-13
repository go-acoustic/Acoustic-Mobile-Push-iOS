/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
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

@interface MCEInAppMediaTemplate : UIViewController

@property IBOutlet UIButton * titleLabel;
@property IBOutlet UIButton * textLabel;
@property IBOutlet UIView * containerView;
@property IBOutlet NSLayoutConstraint * textHeightConstraint;
@property IBOutlet UIButton * contentView;
@property IBOutlet UIView * textLine;
@property IBOutlet UIActivityIndicatorView * spinner;

@property dispatch_queue_t queue;
@property bool autoDismiss;

@property MCEInAppMessage * inAppMessage;


// Only used for disabling vibrantancy selectively
@property NSLayoutConstraint * foreTextHeightConstraint;
@property UIButton * foreTitleLabel;
@property UIButton * foreTextLabel;
@property UIView * foreContainerView;


-(IBAction)dismiss: (id)sender;
-(IBAction)execute: (id)sender;
-(IBAction)expandText:(id)sender;

-(void)setTextHeight;
-(void)autoDismiss: (id)sender;
-(void)showInAppMessage;
-(void)displayInAppMessage:(MCEInAppMessage*)message;

@end
