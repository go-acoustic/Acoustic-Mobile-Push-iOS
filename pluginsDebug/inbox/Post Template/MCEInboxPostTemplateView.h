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

#import "MCEInboxPostTemplateVideoPlayerView.h"
#import "MCEInboxPostTemplate.h"

extern const CGSize HEADER_IMAGE_SIZE;
extern const int MARGIN;

@interface MCEInboxPostTemplateView : UIView
@property IBOutlet UILabel * header;
@property IBOutlet UILabel * subHeader;

@property IBOutlet UIActivityIndicatorView * headerActivity;
@property IBOutlet UIImageView * headerImage;

@property IBOutlet UIActivityIndicatorView * contentActivity;
@property IBOutlet UIButton * contentImage;

@property IBOutlet UILabel * contentText;
@property IBOutlet UIView * container;

@property IBOutlet UIStackView * buttonView;
@property IBOutlet UIButton * leftButton;
@property IBOutlet UIButton * rightButton;
@property IBOutlet UIButton * centerButton;

@property IBOutlet MCEInboxPostTemplateVideoPlayerView * contentVideo;
@property IBOutlet UIActivityIndicatorView * videoActivity;
@property IBOutlet UIImageView * videoPlay;
@property IBOutlet UIView * videoCover;
@property IBOutlet UIProgressView * videoProgress;

@property IBOutlet UIView * contentImageView;
@property IBOutlet UIView * contentVideoView;
@property IBOutlet NSLayoutConstraint * contentConstraint;
@property IBOutlet NSLayoutConstraint * actionMargin;
@property IBOutlet NSLayoutConstraint * headerMargin;
@property IBOutlet NSLayoutConstraint * subheaderMargin;

@property BOOL fullScreen;

-(void)prepareForReuse;
-(void)setInboxMessage:(MCEInboxMessage *)inboxMessage resizeCallback:(void (^)(CGSize, NSURL*, BOOL))resizeCallback;

-(IBAction)startVideo:(id)sender;

-(IBAction)leftButton:(id)sender;
-(IBAction)rightButton:(id)sender;
-(IBAction)centerButton:(id)sender;

-(IBAction)enlargeImage:(id)sender;

@end
