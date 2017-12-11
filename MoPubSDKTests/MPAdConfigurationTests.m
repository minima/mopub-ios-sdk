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
#import "MOPUBExperimentProvider.h"
#import "MPAdConfiguration+Testing.h"
#import "MPViewabilityTracker.h"

@interface MPAdConfigurationTests : XCTestCase

@end

@implementation MPAdConfigurationTests

- (void)setUp {
    [super setUp];
    [MPViewabilityTracker initialize];
}

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

#pragma mark - Clickthrough experiments test

- (void)testClickthroughExperimentDefault {
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:nil data:nil];
    XCTAssertEqual(config.clickthroughExperimentBrowserAgent, MOPUBDisplayAgentTypeInApp);
    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeInApp);
}

- (void)testClickthroughExperimentInApp {
    NSDictionary * headers = @{ kClickthroughExperimentBrowserAgent: @"0"};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
    XCTAssertEqual(config.clickthroughExperimentBrowserAgent, MOPUBDisplayAgentTypeInApp);
    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeInApp);
}

- (void)testClickthroughExperimentNativeBrowser {
    NSDictionary * headers = @{ kClickthroughExperimentBrowserAgent: @"1"};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
    XCTAssertEqual(config.clickthroughExperimentBrowserAgent, MOPUBDisplayAgentTypeNativeSafari);
    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeNativeSafari);
}

- (void)testClickthroughExperimentSafariViewController {
    NSDictionary * headers = @{ kClickthroughExperimentBrowserAgent: @"2"};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
    XCTAssertEqual(config.clickthroughExperimentBrowserAgent, MOPUBDisplayAgentTypeSafariViewController);
    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeSafariViewController);
}

#pragma mark - Viewability

- (void)testDisableAllViewability {
    // IAS should be initially enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);

    // {
    //   "X-Disable-Viewability": 3
    // }
    NSDictionary * headers = @{ kViewabilityDisableHeaderKey: @"3" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    XCTAssertNotNil(config);

    // All viewability vendors should be disabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionNone);
}

- (void)testDisableNoViewability {
    // IAS should be initially enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);

    // {
    //   "X-Disable-Viewability": 0
    // }
    NSDictionary * headers = @{ kViewabilityDisableHeaderKey: @"0" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    XCTAssertNotNil(config);

    // IAS should still be enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);
}

- (void)testEnableAlreadyDisabledViewability {
    // IAS should be initially enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);

    // {
    //   "X-Disable-Viewability": 3
    // }
    NSDictionary * headers = @{ kViewabilityDisableHeaderKey: @"3" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    XCTAssertNotNil(config);

    // All viewability vendors should be disabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionNone);

    // Reset local variables for reuse.
    headers = nil;
    config = nil;

    // {
    //   "X-Disable-Viewability": 0
    // }
    headers = @{ kViewabilityDisableHeaderKey: @"0" };
    config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    XCTAssertNotNil(config);

    // All viewability vendors should still be disabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionNone);
}

- (void)testInvalidViewabilityHeaderValue {
    // IAS should be initially enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);

    // {
    //   "X-Disable-Viewability": 3aaaa
    // }
    NSDictionary * headers = @{ kViewabilityDisableHeaderKey: @"3aaaa" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    XCTAssertNotNil(config);

    // IAS should still be enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);
}

- (void)testEmptyViewabilityHeaderValue {
    // IAS should be initially enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);

    // {
    //   "X-Disable-Viewability": ""
    // }
    NSDictionary * headers = @{ kViewabilityDisableHeaderKey: @"" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    XCTAssertNotNil(config);

    // IAS should still be enabled
    XCTAssertTrue([MPViewabilityTracker enabledViewabilityVendors] == MPViewabilityOptionIAS);
}

#pragma mark - Static Native Ads

- (void)testMinVisiblePixelsParseSuccess {
    NSDictionary *headers = @{ @"X-Native-Impression-Min-Px": @"50" };
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    XCTAssertEqual(config.nativeImpressionMinVisiblePixels, 50.0);
}

- (void)testMinVisiblePixelsParseNoHeader {
    NSDictionary *headers = @{};
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    XCTAssertEqual(config.nativeImpressionMinVisiblePixels, -1.0);
}

- (void)testMinVisiblePercentParseSuccess {
    NSDictionary *headers = @{ @"X-Impression-Min-Visible-Percent": @"50" };
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    XCTAssertEqual(config.nativeImpressionMinVisiblePercent, 50);
}

- (void)testMinVisiblePercentParseNoHeader {
    NSDictionary *headers = @{};
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    XCTAssertEqual(config.nativeImpressionMinVisiblePercent, -1);
}

- (void)testMinVisibleTimeIntervalParseSuccess {
    NSDictionary *headers = @{ @"X-Impression-Visible-Ms": @"1500" };
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    XCTAssertEqual(config.nativeImpressionMinVisibleTimeInterval, 1.5);
}

- (void)testMinVisibleTimeIntervalParseNoHeader {
    NSDictionary *headers = @{};
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    XCTAssertEqual(config.nativeImpressionMinVisibleTimeInterval, -1);
}

#pragma mark - Banner Impression Headers

- (void)testVisibleImpressionHeader {
    NSDictionary * headers = @{ kBannerImpressionVisableMsHeaderKey: @"0", kBannerImpressionMinPixelHeaderKey:@"1"};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
    XCTAssertEqual(config.impressionMinVisiblePixels, 1);
    XCTAssertEqual(config.impressionMinVisibleTimeInSec, 0);
}

- (void)testVisibleImpressionEnabled {
    NSDictionary * headers = @{ kBannerImpressionVisableMsHeaderKey: @"0", kBannerImpressionMinPixelHeaderKey:@"1"};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
    XCTAssertTrue(config.visibleImpressionTrackingEnabled);
}

- (void)testVisibleImpressionEnabledNoHeader {
    NSDictionary * headers = @{};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
    XCTAssertFalse(config.visibleImpressionTrackingEnabled);
}

- (void)testVisibleImpressionNotEnabled {
    NSDictionary * headers = @{kBannerImpressionVisableMsHeaderKey: @"0", kBannerImpressionMinPixelHeaderKey:@"0"};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
    XCTAssertFalse(config.visibleImpressionTrackingEnabled);
}

@end
