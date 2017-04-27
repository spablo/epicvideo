//
//  EpicVideoTests.m
//  EpicVideoTests
//
//  Created by macdroid on 27-04-17.
//  Copyright © 2017 Ep!c>labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "EpicVideoController.h"
#import "EpicVideoStatusDelegate.h"

@interface EpicVideoControllerTests : XCTestCase<EpicVideoStatusDelegate>
@property(nonatomic, strong) EpicVideoController* epicVideoController;
@property(nonatomic, strong) NSURL* testVideoUrl;
@property(nonatomic, strong) XCTestExpectation* videoStatusExpectation;
@end

@implementation EpicVideoControllerTests

- (void)setUp {
    [super setUp];
    self.epicVideoController = [[EpicVideoController alloc] init];
    self.testVideoUrl = [[NSBundle bundleForClass:[self class]] URLForResource:@"sample" withExtension:@"mp4"];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testTogglePlay {
    [self.epicVideoController setVideo:self.testVideoUrl];
    XCTAssertFalse([self.epicVideoController isPlaying]);
    self.videoStatusExpectation = [self expectationWithDescription:@"Video ready to play"];
    self.epicVideoController.delegate = self;
    [self.epicVideoController play];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Video Player Timeout Error: %@", error);
        }
        XCTAssertTrue([self.epicVideoController isPlaying]);
        [self.epicVideoController togglePlay];
        XCTAssertFalse([self.epicVideoController isPlaying]);
    }];
    
}

- (void) statusReady {
    [self.videoStatusExpectation fulfill];
}

@end
