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
@import AVFoundation;
@import UIKit;
#else
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#endif

@interface MCEInboxPostTemplateVideoPlayerView : UIButton
-(void)loadVideoPlayer:(AVPlayer*)player;
-(void)unloadVideoPlayer;
@end
