//
//  EpicVideoPlayerView.h
//  EpicVideo
//
//  Created by macdroid on 27-04-17.
//  Copyright © 2017 Ep!c>labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "EpicVideoPlayer.h"

@interface EpicVideoPlayerView : UIView

@property(nonatomic, weak) id<EpicVideoPlayer> playerDelegate;

/**
 * Set AVPlayer that should direct its visual output to this UIView.
 */
- (void) setPlayer:(AVPlayer *) player;

/**
 * Update the view with the given time progress.
 * @param current current time of playing item
 * @param duration total duration of playing item
 */
- (void) updateProgress: (CMTime) current duration: (CMTime) duration;

/**
 * Update the view with the given playing state.
 */
- (void) updatePlayState: (BOOL) isPlaying;

/**
 * Enable/Disable controls of the player view.
 */
- (void) setEnabled:(BOOL) enabled;

@end
