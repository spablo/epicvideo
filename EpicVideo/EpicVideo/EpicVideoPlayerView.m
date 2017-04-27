//
//  EpicVideoPlayerView.m
//  EpicVideo
//
//  Created by macdroid on 27-04-17.
//  Copyright © 2017 Ep!c>labs. All rights reserved.
//

#import "EpicVideoPlayerView.h"

#import "EpicVideoView.h"

#define PLAY_TITLE @"|>"
#define PAUSE_TITLE @"||"

@interface EpicVideoPlayerView()
@property(nonatomic, strong) EpicVideoView *epicVideoView;
@property(nonatomic, strong) UIButton *playButton;
@property(nonatomic, strong) UISlider *seekSlider;
@property(nonatomic, strong) UIView *controlBar;
@end


@implementation EpicVideoPlayerView

#pragma mark - Override UIView methods -

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    // Create View Components
    self.epicVideoView = [[EpicVideoView alloc] init];
    self.epicVideoView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview: self.epicVideoView];
    
    self.controlBar = [[UIView alloc] init];
    self.controlBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview: self.controlBar];
    
    self.playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.playButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.playButton setTitle:PLAY_TITLE forState:UIControlStateNormal];
    self.playButton.titleLabel.font = [UIFont boldSystemFontOfSize:25.0];
    [self.playButton addTarget:self action:@selector(togglePlay:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlBar addSubview: self.playButton];
    
    self.seekSlider = [[UISlider alloc] init];
    self.seekSlider.translatesAutoresizingMaskIntoConstraints = NO;
    self.seekSlider.continuous = YES;
    [self.seekSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.controlBar addSubview: self.seekSlider];
    
    
    // Setup Layout
    NSDictionary *views = @{@"video":self.epicVideoView, @"control": self.controlBar, @"play": self.playButton, @"seek": self.seekSlider};
    NSDictionary *metrics = @{@"size":@32.0,@"padding":@5.0};
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[video]|" options:0 metrics:metrics views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[video]-padding-[control(size)]|" options:NSLayoutFormatAlignAllLeading | NSLayoutFormatAlignAllTrailing metrics:metrics views:views]];
    [self.controlBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-padding-[play(size)]-padding-[seek]-padding-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
    [self.controlBar addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[play]|" options:0 metrics:metrics views:views]];
}

#pragma mark - EpicVideoPlayerView methods -

- (void) setPlayer:(AVPlayer *) player {
    [self.epicVideoView setPlayer:player];
}

- (void) setEnabled:(BOOL) enabled {
    self.seekSlider.enabled = enabled;
    self.playButton.enabled = enabled;
}

- (void) updateProgress: (CMTime) current duration: (CMTime) duration {
    // If total duration is invalid or not defined (e.g.: live stream), disable progress/seek slider
    if(CMTIME_IS_INVALID(duration)) {
        self.seekSlider.enabled = NO;
        return;
    }
    
    if(CMTIME_IS_INDEFINITE(duration)) {
        self.seekSlider.enabled = NO;
    } else {
        self.seekSlider.enabled = YES;
        self.seekSlider.maximumValue = CMTimeGetSeconds(duration);
        self.seekSlider.value = CMTimeGetSeconds(current);
    }
}

- (void) updatePlayState: (BOOL) isPlaying {
    [self.playButton setTitle: isPlaying ? PAUSE_TITLE : PLAY_TITLE forState:UIControlStateNormal];
}

#pragma mark - Action methods -

- (void) togglePlay: (UIBarButtonItem*) sender {
    if(self.playerDelegate)
        [self.playerDelegate togglePlay];
}

- (void) sliderValueChanged: (UISlider*) sender {
    if(self.playerDelegate)
        [self.playerDelegate seekToTime: CMTimeMake(sender.value, 1)];
}


@end
