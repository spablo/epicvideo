//
//  EpicVideoPlayer.h
//  EpicVideo
//
//  Created by macdroid on 27-04-17.
//  Copyright © 2017 Ep!c>labs. All rights reserved.
//

#import <CoreMedia/CoreMedia.h>

@protocol EpicVideoPlayer

- (void) setVideo: (NSURL*) url;

- (BOOL) isPlaying;
- (void) togglePlay;
- (void) play;
- (void) pause;
- (void) stop;
- (void) seekToTime: (CMTime)time;

- (CMTime) getDuration;
- (CMTime) getCurrentTime;

- (CGSize) getResolution;
- (float) getFrameRate;

- (float) getVideoBitRate;
- (float) getAudioBitRate;

- (NSArray*) getVideoCodecs;
- (NSArray*) getAudioCodecs;
- (NSArray*) getCodecs;

@end
