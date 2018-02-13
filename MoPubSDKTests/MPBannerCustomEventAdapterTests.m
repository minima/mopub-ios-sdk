//
//  MPBannerCustomEventAdapterTests.m
//  MoPubSDKTests
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPAdConfiguration.h"
#import "MPBannerCustomEvent.h"
#import "MPHTMLBannerCustomEvent.h"
#import "MPMRAIDBannerCustomEvent.h"
#import "MPBannerCustomEventAdapter+Testing.h"

@interface MPBannerCustomEventAdapterTests : XCTestCase

@end

@implementation MPBannerCustomEventAdapterTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// When an AD is in the imp tracking experiment, banner impressions (include all banner formats) are fired from SDK.
- (void)testShouldTrackImpOnDisplayWhenExperimentEnabled {
    NSDictionary *headers = @{ kBannerImpressionVisableMsHeaderKey: @"0", kBannerImpressionMinPixelHeaderKey:@"1"};
    MPAdConfiguration *config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    MPBannerCustomEventAdapter *adapter = [MPBannerCustomEventAdapter new];

    adapter.configuration = config;

    [adapter didDisplayAd];

    XCTAssertFalse(adapter.hasTrackedImpression);
}

// When an AD is not in the imp tracking experiment, banner impressions are fired from SDK for base class.
- (void)testImpFiredWhenAutoTrackingEnabledForBaseBannerAndExperimentDisabled {
    MPAdConfiguration *config = [MPAdConfiguration new];

    MPBannerCustomEventAdapter *adapter = [MPBannerCustomEventAdapter new];
    adapter.configuration = config;

    MPBannerCustomEvent *customEvent = [MPBannerCustomEvent new];
    adapter.bannerCustomEvent = customEvent;
    adapter.hasTrackedImpression = NO;

    [adapter didDisplayAd];

    XCTAssertTrue(adapter.hasTrackedImpression);
}

// When an AD is not in the imp tracking experiment, banner impressions are fired from JS directly. SDK doesn't fire impression.
- (void)testImpFiredWhenAutoTrackingEnabledForHtmlAndExperimentDisabled {
    MPAdConfiguration *config = [MPAdConfiguration new];

    MPBannerCustomEventAdapter *adapter = [MPBannerCustomEventAdapter new];
    adapter.configuration = config;

    MPBannerCustomEvent *customEvent = [MPHTMLBannerCustomEvent new];
    adapter.bannerCustomEvent = customEvent;
    adapter.hasTrackedImpression = NO;

    [adapter didDisplayAd];

    XCTAssertFalse(adapter.hasTrackedImpression);
}

// When an AD is not in the imp tracking experiment, MRAID banner impressions are fired from SDK.
- (void)testImpFiredWhenAutoTrackingEnabledForMraidAndExperimentDisabled {
    MPAdConfiguration *config = [MPAdConfiguration new];

    MPBannerCustomEventAdapter *adapter = [MPBannerCustomEventAdapter new];
    adapter.configuration = config;

    MPBannerCustomEvent *customEvent = [MPMRAIDBannerCustomEvent new];
    adapter.bannerCustomEvent = customEvent;
    adapter.hasTrackedImpression = NO;

    [adapter didDisplayAd];

    XCTAssertTrue(adapter.hasTrackedImpression);
}

@end
