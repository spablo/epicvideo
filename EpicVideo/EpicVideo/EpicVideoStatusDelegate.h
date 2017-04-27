//
//  EpicVideoStatusDelegate.h
//  EpicVideo
//
//  Created by macdroid on 27-04-17.
//  Copyright © 2017 Ep!c>labs. All rights reserved.
//

@protocol EpicVideoStatusDelegate
@optional
-(void) statusReady;
-(void) statusError: (NSError*) error;
@end
