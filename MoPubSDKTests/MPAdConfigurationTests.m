//
//  MPAdConfigurationTests.m
//  MoPubSDK
//
//  Copyright © 2016 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPAdConfiguration.h"
#import "MPAdConfigurationFactory.h"
#import "MPVASTTrackingEvent.h"

@interface MPAdConfigurationTests : XCTestCase

@end

@implementation MPAdConfigurationTests

- (void)testRewardedPlayableDurationParseSuccess {
    NSDictionary * headers = @{ kRewardedPlayableDurationHeaderKey: @"30" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    XCTAssertEqual(config.rewardedPlayableDuration, 30);
}

- (void)testRewardedPlayableDurationParseNoHeader {
    NSDictionary * headers = @{ };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    XCTAssertEqual(config.rewardedPlayableDuration, -1);
}

- (void)testRewardedPlayableRewardOnClickParseSuccess {
    NSDictionary * headers = @{ kRewardedPlayableRewardOnClickHeaderKey: @"true" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    XCTAssertEqual(config.rewardedPlayableShouldRewardOnClick, true);
}

- (void)testRewardedPlayableRewardOnClickParseNoHeader {
    NSDictionary * headers = @{ };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    XCTAssertEqual(config.rewardedPlayableShouldRewardOnClick, false);
}

- (void)testNativeVideoTrackersNoHeader
{
    MPAdConfiguration *config = [MPAdConfigurationFactory defaultNativeAdConfiguration];
    XCTAssertNil(config.nativeVideoTrackers);
}

// @"{
//    "urls": ["http://mopub.com/%%VIDEO_EVENT%%/foo", "http://mopub.com/%%VIDEO_EVENT%%/bar"],
//    "events": ["start", "firstQuartile", "midpoint", "thirdQuartile", "complete"]
//   }"
- (void)testNaiveVideoTrackers {
    MPAdConfiguration *config = [MPAdConfigurationFactory defaultNativeVideoConfigurationWithVideoTrackers];
    XCTAssertNotNil(config.nativeVideoTrackers);
    XCTAssertEqual(config.nativeVideoTrackers.count, 5);
    XCTAssertEqual(((NSArray *)config.nativeVideoTrackers[MPVASTTrackingEventTypeStart]).count, 2);
    XCTAssertEqual(((NSArray *)config.nativeVideoTrackers[MPVASTTrackingEventTypeFirstQuartile]).count, 2);
    XCTAssertEqual(((NSArray *)config.nativeVideoTrackers[MPVASTTrackingEventTypeMidpoint]).count, 2);
    XCTAssertEqual(((NSArray *)config.nativeVideoTrackers[MPVASTTrackingEventTypeThirdQuartile]).count, 2);
    XCTAssertEqual(((NSArray *)config.nativeVideoTrackers[MPVASTTrackingEventTypeComplete]).count, 2);
}

@end
