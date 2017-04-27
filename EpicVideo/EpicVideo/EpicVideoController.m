//
//  EpicVideoController.m
//  EpicVideo
//
//  Created by macdroid on 27-04-17.
//  Copyright © 2017 Ep!c>labs. All rights reserved.
//

#import "EpicVideoController.h"

#import "EpicVideoPlayerView.h"

@interface EpicVideoController ()
@property(nonatomic, strong) AVPlayer* avPlayer;
@property(nonatomic, strong) AVAssetTrack* videoTrack;
@property(nonatomic, strong) AVAssetTrack* audioTrack;
@property(nonatomic, strong) id timeObserver;
@end

@implementation EpicVideoController

#pragma mark - Override methods -

- (void) setVideoView:(EpicVideoPlayerView *)videoView {
    _videoView = videoView;
    if(_videoView)
        _videoView.playerDelegate = self;
}

- (void)dealloc {
    [self removePeriodicTimeObserver];
    [self removeObservers: [self.avPlayer currentItem]];
    [self.avPlayer replaceCurrentItemWithPlayerItem: nil];
    self.avPlayer = nil;
}

#pragma mark - EpicPlayerDelegate delegate methods -

- (void) setVideo: (NSURL*) url {
    if(url == nil)
        return;
    [self enablePlayer: NO];
    
    AVAsset* avAsset = [AVURLAsset URLAssetWithURL:url options: @{AVURLAssetPreferPreciseDurationAndTimingKey: [NSNumber numberWithBool:YES]}];
    self.videoTrack = [[avAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    self.audioTrack = [[avAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    AVPlayerItem* item = [AVPlayerItem playerItemWithAsset: avAsset];
    
    if(self.avPlayer) {
        [self stop];
        [self removeObservers: self.avPlayer.currentItem];
        [self.avPlayer replaceCurrentItemWithPlayerItem: item];
    } else {
        self.avPlayer = [AVPlayer playerWithPlayerItem:item];
        [self.videoView setPlayer: self.avPlayer];
    }
    
    // Add Observers
    [self addPeriodicTimeObserver];
    [self addObservers: item];
    
}

- (BOOL) isPlaying {
    if(self.avPlayer) {
        return self.avPlayer.rate != 0.0;
    }
    return NO;
}

- (void) togglePlay {
    if([self isPlaying]) {
        [self pause];
    } else {
        [self play];
    }
}

- (void) play {
    if(self.avPlayer) {
        [self.avPlayer play];
        [self updatePlayState: YES];
    }
}

- (void) pause {
    if(self.avPlayer) {
        [self.avPlayer pause];
        [self updatePlayState: NO];
    }
}

- (void) stop {
    [self pause];
    [self seekToTime: kCMTimeZero];
}

- (void) seekToTime: (CMTime)time {
    if(self.avPlayer) {
        [self.avPlayer seekToTime: time];
        [self updateProgress:time];
    }
}

- (CMTime) getDuration {
    if(self.avPlayer) {
        return self.avPlayer.currentItem.duration;
    }
    return kCMTimeIndefinite;
}

- (CMTime) getCurrentTime {
    if(self.avPlayer) {
        return self.avPlayer.currentItem.currentTime;
    }
    return kCMTimeZero;
}

- (CGSize) getResolution {
    if(!self.videoTrack)
        return CGSizeZero;
    return self.videoTrack.naturalSize;
}

- (float) getFrameRate {
    if(!self.videoTrack)
        return 0.0;
    return self.videoTrack.nominalFrameRate;
}

- (float) getVideoBitRate {
    return [self getBitRate:self.videoTrack];
}

- (float) getAudioBitRate {
    return [self getBitRate:self.audioTrack];
}

- (float) getBitRate: (AVAssetTrack*) track {
    if(!track)
        return 0.0;
    return track.estimatedDataRate;
}

- (NSArray*) getVideoCodecs {
    return [self getCodecs: self.videoTrack];
}

- (NSArray*) getAudioCodecs {
    return [self getCodecs: self.audioTrack];
}

- (NSArray*) getCodecs {
    return [[self getVideoCodecs] arrayByAddingObjectsFromArray:[self getAudioCodecs]];
}

- (NSArray*) getCodecs: (AVAssetTrack*) track {
    if(!track)
        return [NSArray array];

    NSMutableArray* codecs = [NSMutableArray array];
    for (id formatDescription in track.formatDescriptions) {
        [codecs addObject: [self getCodecString:formatDescription]];
    }
    return [codecs copy];
}

// See http://stackoverflow.com/questions/11194609/retrieving-movie-codec-under-ios
- (NSString*) getCodecString: (id) formatDescription {
    CMFormatDescriptionRef desc = (__bridge CMFormatDescriptionRef)formatDescription;
    // Get the codec and correct endianness
    CMVideoCodecType formatCodec = CFSwapInt32BigToHost(CMFormatDescriptionGetMediaSubType(desc));
    // add 1 for null terminator
    char formatCodecBuf[sizeof(CMVideoCodecType) + 1] = {0};
    memcpy(formatCodecBuf, &formatCodec, sizeof(CMVideoCodecType));
    return @(formatCodecBuf);
}

#pragma mark - Observer register/unregister methods -

- (void) addObservers: (AVPlayerItem*) item {
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stop) name:AVPlayerItemFailedToPlayToEndTimeNotification object:item];
}

- (void) removeObservers: (AVPlayerItem*) item {
    [item removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) addPeriodicTimeObserver {
    [self removePeriodicTimeObserver];
    __weak EpicVideoController *weakSelf = self;
    self.timeObserver = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC)
                                                                        queue:dispatch_get_main_queue()
                                                                    usingBlock:^(CMTime time) {
                                                                    [weakSelf updateProgress:time];
                                                                    }];
}

- (void) removePeriodicTimeObserver {
    if (self.timeObserver) {
        [self.avPlayer removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (self.avPlayer && object == self.avPlayer.currentItem) {
        if ([keyPath isEqualToString:@"status"]) {
            AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
            switch (status) {
                case AVPlayerStatusReadyToPlay:
                    [self enablePlayer: YES];
                    if(self.delegate)
                        [self.delegate statusReady];
                    break;
                case AVPlayerStatusFailed:
                    [self removePeriodicTimeObserver];
                    [self removeObservers: self.avPlayer.currentItem];
                    self.avPlayer = nil;
                    if(self.delegate)
                        [self.delegate statusError: self.avPlayer.currentItem.error];
                    break;
                case AVPlayerStatusUnknown:
                    break;
            }
        }
    }
}

#pragma mark - View update methods -

- (void) updateProgress: (CMTime) time {
    if(self.videoView) {
        [self.videoView updateProgress:time duration:[self getDuration]];
    }
}

- (void) updatePlayState: (BOOL) isPlaying {
    if(self.videoView) {
        [self.videoView updatePlayState: isPlaying];
    }
}

- (void) enablePlayer: (BOOL) enable {
    if(self.videoView) {
        [self.videoView setEnabled: enable];
    }
}

@end
