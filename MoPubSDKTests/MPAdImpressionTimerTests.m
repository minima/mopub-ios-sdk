//
//  MPBannerAdImpressionTimerTests.m
//  MoPubSDKTests
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPAdImpressionTimer.h"

@interface MPAdImpressionTimer()

@property (nonatomic, assign) NSTimeInterval firstVisibilityTimestamp;

@end

@interface MPBannerAdImpressionTimerTests : XCTestCase

@property (nonatomic) MPAdImpressionTimer *impressionTimer;

@end

@implementation MPBannerAdImpressionTimerTests

- (void)setUp {
    [super setUp];
    self.impressionTimer = [[MPAdImpressionTimer alloc] initWithRequiredSecondsForImpression:0 requiredViewVisibilityPixels:1];
}

- (void)testTimerInitialization {
    XCTAssertEqual(self.impressionTimer.firstVisibilityTimestamp, -1);
}

@end
