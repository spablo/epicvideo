//
//  EpicVideoView.h
//  EpicVideo
//
//  Created by macdroid on 27-04-17.
//  Copyright © 2017 Ep!c>labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface EpicVideoView : UIView

/**
 * Set AVPlayer that should direct its visual output to this UIView.
 */
- (void) setPlayer:(AVPlayer *) player;

@end
