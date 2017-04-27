//
//  EpicVideoController.h
//  EpicVideo
//
//  Created by macdroid on 27-04-17.
//  Copyright © 2017 Ep!c>labs. All rights reserved.
//

#import "EpicVideoPlayer.h"
#import "EpicVideoStatusDelegate.h"

@class EpicVideoPlayerView;

@interface EpicVideoController : NSObject<EpicVideoPlayer>

@property(nonatomic, weak) IBOutlet EpicVideoPlayerView *videoView;
@property(nonatomic, weak) IBOutlet id<EpicVideoStatusDelegate> delegate;

@end
