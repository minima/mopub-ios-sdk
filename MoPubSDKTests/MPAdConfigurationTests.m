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
#import "MPRewardedVideoReward.h"

@interface MPAdConfigurationTests : XCTestCase

@end

@implementation MPAdConfigurationTests

#pragma mark - Rewarded Ads

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

- (void)testRewardedSingleCurrencyParseSuccess {
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameHeaderKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountHeaderKey: @"3",
                               };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    XCTAssertNotNil(config.availableRewards);
    XCTAssertNotNil(config.selectedReward);
    XCTAssertEqual(config.availableRewards.count, 1);
    XCTAssertEqual(config.availableRewards[0], config.selectedReward);
    XCTAssert([config.selectedReward.currencyType isEqualToString:@"Diamonds"]);
    XCTAssert(config.selectedReward.amount.integerValue == 3);
}

- (void)testRewardedMultiCurrencyParseSuccess {
    // {
    //   "rewards": [
    //     { "name": "Coins", "amount": 8 },
    //     { "name": "Diamonds", "amount": 1 },
    //     { "name": "Energy", "amount": 20 }
    //   ]
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesHeaderKey: @"{ \"rewards\": [ { \"name\": \"Coins\", \"amount\": 8 }, { \"name\": \"Diamonds\", \"amount\": 1 }, { \"name\": \"Energy\", \"amount\": 20 } ] }" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    XCTAssertNotNil(config.availableRewards);
    XCTAssertNotNil(config.selectedReward);
    XCTAssertEqual(config.availableRewards.count, 3);
    XCTAssertEqual(config.availableRewards[0], config.selectedReward);
    XCTAssert([config.selectedReward.currencyType isEqualToString:@"Coins"]);
    XCTAssert(config.selectedReward.amount.integerValue == 8);
}

- (void)testRewardedMultiCurrencyParseFailure {
    // {
    //   "rewards": []
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesHeaderKey: @"{ \"rewards\": [] }" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    XCTAssertNotNil(config.availableRewards);
    XCTAssertNotNil(config.selectedReward);
    XCTAssertEqual(config.availableRewards.count, 1);
    XCTAssertEqual(config.availableRewards[0], config.selectedReward);
    XCTAssert([config.selectedReward.currencyType isEqualToString:kMPRewardedVideoRewardCurrencyTypeUnspecified]);
    XCTAssert(config.selectedReward.amount.integerValue == kMPRewardedVideoRewardCurrencyAmountUnspecified);
}

- (void)testRewardedMultiCurrencyParseFailureMalconfiguredReward {
    // {
    //   "rewards": [ { "n": "Coins", "a": 8 } ]
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesHeaderKey: @"{ \"rewards\": [ { \"n\": \"Coins\", \"a\": 8 } ] }" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    XCTAssertNotNil(config.availableRewards);
    XCTAssertNotNil(config.selectedReward);
    XCTAssertEqual(config.availableRewards.count, 1);
    XCTAssertEqual(config.availableRewards[0], config.selectedReward);
    XCTAssert([config.selectedReward.currencyType isEqualToString:kMPRewardedVideoRewardCurrencyTypeUnspecified]);
    XCTAssert(config.selectedReward.amount.integerValue == kMPRewardedVideoRewardCurrencyAmountUnspecified);
}

- (void)testRewardedMultiCurrencyParseFailoverToSingleCurrencySuccess {
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameHeaderKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountHeaderKey: @"3",
                                kRewardedCurrenciesHeaderKey: @"{ }"
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    XCTAssertNotNil(config.availableRewards);
    XCTAssertNotNil(config.selectedReward);
    XCTAssertEqual(config.availableRewards.count, 1);
    XCTAssertEqual(config.availableRewards[0], config.selectedReward);
    XCTAssert([config.selectedReward.currencyType isEqualToString:@"Diamonds"]);
    XCTAssert(config.selectedReward.amount.integerValue == 3);
}

#pragma mark - Native Trackers

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
