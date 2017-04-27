//
//  EpicVideoView.m
//  EpicVideo
//
//  Created by macdroid on 27-04-17.
//  Copyright © 2017 Ep!c>labs. All rights reserved.
//

#import "EpicVideoView.h"

@interface EpicVideoView()
@property(readonly) AVPlayerLayer *playerLayer;
@end

@implementation EpicVideoView

#pragma mark - Override UIView methods -

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

#pragma mark - EpicVideoView methods -

- (void)setPlayer:(AVPlayer *)player {
    self.playerLayer.player = player;
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

@end
