//
//  MoPubTests.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MoPub.h"
#import "MPAdConfiguration.h"
#import "MPRewardedVideoCustomEvent+Caching.h"
#import "MPMockAdColonyRewardedVideoCustomEvent.h"
#import "MPMockChartboostRewardedVideoCustomEvent.h"
#import "MPWebView+Testing.h"
#import "MRController.h"
#import "MRController+Testing.h"

static NSTimeInterval const kTestTimeout = 2;

@interface MoPubTests : XCTestCase <MPRewardedVideoDelegate>

@end

@implementation MoPubTests

- (void)setUp {
    [super setUp];
    [MPRewardedVideoCustomEvent clearCache];

    [MoPub sharedInstance].forceWKWebView = NO;
    [MoPub sharedInstance].logLevel = MPLogLevelInfo;
}

#pragma mark - Rewarded Video

- (void)testInitializingNetworkFromCache {
    // Reset initialized state
    [MPMockAdColonyRewardedVideoCustomEvent reset];
    [MPMockChartboostRewardedVideoCustomEvent reset];
    XCTAssertFalse([MPMockAdColonyRewardedVideoCustomEvent isSdkInitialized]);
    XCTAssertFalse([MPMockChartboostRewardedVideoCustomEvent isSdkInitialized]);

    // Put data into the cache to simulate having been cache prior.
    [MPRewardedVideoCustomEvent setCachedInitializationParameters:@{ @"appId": @"aaaa" } forNetwork:@"MPMockAdColonyRewardedVideoCustomEvent"];
    [MPRewardedVideoCustomEvent setCachedInitializationParameters:@{ @"appId": @"bbbb" } forNetwork:@"MPMockChartboostRewardedVideoCustomEvent"];

    // Initialize
    [[MoPub sharedInstance] initializeRewardedVideoWithGlobalMediationSettings:nil delegate:nil];

    // Wait for SDKs to initialize
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect timer to fire"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kTestTimeout / 2.0) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // Verify initialized sdks
    XCTAssertTrue([MPMockAdColonyRewardedVideoCustomEvent isSdkInitialized]);
    XCTAssertTrue([MPMockChartboostRewardedVideoCustomEvent isSdkInitialized]);
}

- (void)testPartialInitializingNetworkFromCache {
    // Reset initialized state
    [MPMockAdColonyRewardedVideoCustomEvent reset];
    [MPMockChartboostRewardedVideoCustomEvent reset];
    XCTAssertFalse([MPMockAdColonyRewardedVideoCustomEvent isSdkInitialized]);
    XCTAssertFalse([MPMockChartboostRewardedVideoCustomEvent isSdkInitialized]);

    // Put data into the cache to simulate having been cache prior.
    [MPRewardedVideoCustomEvent setCachedInitializationParameters:@{ @"appId": @"aaaa" } forNetwork:@"MPMockAdColonyRewardedVideoCustomEvent"];
    [MPRewardedVideoCustomEvent setCachedInitializationParameters:@{ @"appId": @"bbbb" } forNetwork:@"MPMockChartboostRewardedVideoCustomEvent"];

    // Initialize
    [[MoPub sharedInstance] initializeRewardedVideoWithGlobalMediationSettings:nil delegate:nil networkInitializationOrder:@[@"MPMockAdColonyRewardedVideoCustomEvent"]];

    // Wait for SDKs to initialize
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect timer to fire"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kTestTimeout / 2.0) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    // Verify initialized sdks
    XCTAssertTrue([MPMockAdColonyRewardedVideoCustomEvent isSdkInitialized]);
    XCTAssertFalse([MPMockChartboostRewardedVideoCustomEvent isSdkInitialized]);
}

- (void)testNoInitializingNetworkFromCache {
    // Reset initialized state
    [MPMockAdColonyRewardedVideoCustomEvent reset];
    [MPMockChartboostRewardedVideoCustomEvent reset];
    XCTAssertFalse([MPMockAdColonyRewardedVideoCustomEvent isSdkInitialized]);
    XCTAssertFalse([MPMockChartboostRewardedVideoCustomEvent isSdkInitialized]);

    // Put data into the cache to simulate having been cache prior.
    [MPRewardedVideoCustomEvent setCachedInitializationParameters:@{ @"appId": @"aaaa" } forNetwork:@"MPMockAdColonyRewardedVideoCustomEvent"];
    [MPRewardedVideoCustomEvent setCachedInitializationParameters:@{ @"appId": @"bbbb" } forNetwork:@"MPMockChartboostRewardedVideoCustomEvent"];

    // Initialize
    [[MoPub sharedInstance] initializeRewardedVideoWithGlobalMediationSettings:nil delegate:nil networkInitializationOrder:nil];

    // Verify initialized sdks
    XCTAssertFalse([MPMockAdColonyRewardedVideoCustomEvent isSdkInitialized]);
    XCTAssertFalse([MPMockChartboostRewardedVideoCustomEvent isSdkInitialized]);
}

- (void)testBadInitializingNetworkFromCache {
    // Reset initialized state
    [MPMockAdColonyRewardedVideoCustomEvent reset];
    [MPMockChartboostRewardedVideoCustomEvent reset];
    XCTAssertFalse([MPMockAdColonyRewardedVideoCustomEvent isSdkInitialized]);
    XCTAssertFalse([MPMockChartboostRewardedVideoCustomEvent isSdkInitialized]);

    // Put data into the cache to simulate having been cache prior.
    [MPRewardedVideoCustomEvent setCachedInitializationParameters:@{ @"appId": @"aaaa" } forNetwork:@"MPMockAdColonyRewardedVideoCustomEvent"];
    [MPRewardedVideoCustomEvent setCachedInitializationParameters:@{ @"appId": @"bbbb" } forNetwork:@"MPMockChartboostRewardedVideoCustomEvent"];

    // Initialize
    [[MoPub sharedInstance] initializeRewardedVideoWithGlobalMediationSettings:nil delegate:nil networkInitializationOrder:@[@"NON_EXISTANT_REWARDED_CLASS"]];

    // Verify initialized sdks
    XCTAssertFalse([MPMockAdColonyRewardedVideoCustomEvent isSdkInitialized]);
    XCTAssertFalse([MPMockChartboostRewardedVideoCustomEvent isSdkInitialized]);
}

#pragma mark - WKWebView

- (void)testNoForceWKWebView {
    // Normal WKWebView behavior
    [MoPub sharedInstance].forceWKWebView = NO;

    // Verify that UIWebView was used instead of WKWebView for video ads
    NSDictionary * headers = @{ kAdTypeHeaderKey: @"rewarded_video",
                                kIsVastVideoPlayerKey: @(1),
                                kRewardedCurrenciesHeaderKey: @"{ \"rewards\": [ { \"name\": \"Coins\", \"amount\": 8 }, { \"name\": \"Diamonds\", \"amount\": 1 }, { \"name\": \"Energy\", \"amount\": 20 } ] }"
                                };

    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    MRController * controller = [[MRController alloc] initWithAdViewFrame:CGRectZero adPlacementType:MRAdViewPlacementTypeInterstitial];
    [controller loadAdWithConfiguration:config];

    XCTAssertNil(controller.mraidWebView.wkWebView);
    XCTAssertNotNil(controller.mraidWebView.uiWebView);
}

- (void)testForceWKWebView {
    // Force WKWebView
    [MoPub sharedInstance].forceWKWebView = YES;

    // Verify that WKWebView was used instead of UIWebView for video ads
    NSDictionary * headers = @{ kAdTypeHeaderKey: @"rewarded_video",
                                kIsVastVideoPlayerKey: @(1),
                                kRewardedCurrenciesHeaderKey: @"{ \"rewards\": [ { \"name\": \"Coins\", \"amount\": 8 }, { \"name\": \"Diamonds\", \"amount\": 1 }, { \"name\": \"Energy\", \"amount\": 20 } ] }"
                                };

    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    MRController * controller = [[MRController alloc] initWithAdViewFrame:CGRectZero adPlacementType:MRAdViewPlacementTypeInterstitial];
    [controller loadAdWithConfiguration:config];

    XCTAssertNotNil(controller.mraidWebView.wkWebView);
    XCTAssertNil(controller.mraidWebView.uiWebView);
}

#pragma mark - Logging

- (void)testSetLogLevel {
    [MoPub sharedInstance].logLevel = MPLogLevelFatal;

    XCTAssertTrue([MoPub sharedInstance].logLevel == MPLogLevelFatal);
}

@end
