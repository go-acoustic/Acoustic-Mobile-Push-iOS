/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "MCEInAppVideoPlayerView.h"

@interface MCEInAppVideoPlayerView ()
@property AVPlayerLayer *playerLayer;
@end

@implementation MCEInAppVideoPlayerView

- (void)layoutSubviews
{
    self.playerLayer.frame = self.bounds;
}

-(void)loadVideoPlayer:(AVPlayer*)player
{
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    self.playerLayer.frame = self.bounds;
    [self.layer addSublayer:self.playerLayer];
}

-(void)unloadVideoPlayer
{
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
}

@end
