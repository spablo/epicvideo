//
//  EpicVideoPlayerViewController.m
//  EpicVideoExample
//
//  Created by macdroid on 27-04-17.
//  Copyright © 2017 Ep!c>labs. All rights reserved.
//

#import "EpicVideoPlayerViewController.h"

#import <EpicVideo/EpicVideoController.h>

@interface EpicVideoPlayerViewController ()
@property(nonatomic, weak) IBOutlet EpicVideoController* epicVideoController;
@property(nonatomic, weak) IBOutlet UILabel* lblDuration;
@property(nonatomic, weak) IBOutlet UILabel* lblResolution;
@property(nonatomic, weak) IBOutlet UILabel* lblFrameRate;
@property(nonatomic, weak) IBOutlet UILabel* lblBitRate;
@property(nonatomic, weak) IBOutlet UILabel* lblCodecs;
@end

@implementation EpicVideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"EpicLabsAwesomeTeam" withExtension:@"mp4"];
    //NSURL* url = [NSURL URLWithString:@"https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"];
    [self.epicVideoController setVideo:url];
    
    [self updateDuration];
    
    CGSize resolution = [self.epicVideoController getResolution];
    [self.lblResolution setText: [NSString stringWithFormat:NSLocalizedString(@"Resolution: %.f x %.f", nil), resolution.width, resolution.height]];
    
    [self.lblFrameRate setText: [NSString stringWithFormat:NSLocalizedString(@"FrameRate: %.02f fps", nil), [self.epicVideoController getFrameRate]]];
    
    [self.lblBitRate setText: [NSString stringWithFormat:NSLocalizedString(@"BitRate: %.f kbps (video) | %.f kbps (audio)", nil), [self.epicVideoController getVideoBitRate]/1024.0, [self.epicVideoController getAudioBitRate]/1024.0]];
    
    [self.lblCodecs setText: [NSString stringWithFormat:NSLocalizedString(@"Codecs: %@", nil), [[self.epicVideoController getCodecs] componentsJoinedByString: @","]]];
}

- (void) updateDuration {
    CMTime duration = [self.epicVideoController getDuration];
    if(CMTIME_IS_NUMERIC(duration)) {
        [self.lblDuration setText: [NSString stringWithFormat:NSLocalizedString(@"Duration: %.f seconds", nil), CMTimeGetSeconds(duration)]];
    } else {
        [self.lblDuration setText: NSLocalizedString(@"Duration: Unknown", nil)];
    }
}

-(void) statusReady {
    [self updateDuration];
}


@end
