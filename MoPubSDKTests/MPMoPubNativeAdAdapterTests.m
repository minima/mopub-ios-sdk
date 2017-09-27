//
//  MPMoPubNativeAdAdapterTests.m
//  MoPubSDKTests
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPMoPubNativeAdAdapter+Testing.m"
#import "MPStaticNativeAdImpressionTimer+Testing.h"
#import "MPNativeAdConstants.h"
#import "MPNativeAdConfigValues.h"

@interface MPMoPubNativeAdAdapterTests : XCTestCase

@end

@implementation MPMoPubNativeAdAdapterTests

#pragma mark: Impression timer gets set correctly

- (void)testImpressionRulesTimerSetFromHeaderProperties {
    MPNativeAdConfigValues *configValues = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePercent:30
                                                                                   impressionMinVisibleSeconds:5.0];
    NSDictionary *properties = @{ kImpressionTrackerURLsKey: @[@"https://google.com"], // required for adapter to initialize
                                  kClickTrackerURLKey: @"https://google.com", // required for adapter to initialize
                                  kNativeAdConfigKey: configValues,
                                  };
    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[NSMutableDictionary dictionaryWithDictionary:properties]];

    XCTAssertEqual(adapter.impressionTimer.requiredSecondsForImpression, configValues.impressionMinVisibleSeconds);
    CGFloat percentage = (configValues.impressionMinVisiblePercent / 100.0);
    XCTAssertEqual(adapter.impressionTimer.requiredViewVisibilityPercentage, percentage);
}

- (void)testImpressionRulesDefaultsAreUsedWhenHeaderPropertiesAreInvalid {
    MPNativeAdConfigValues *configValues = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePercent:-1
                                                                                   impressionMinVisibleSeconds:-1.0];
    NSDictionary *properties = @{ kImpressionTrackerURLsKey: @[@"https://google.com"], // required for adapter to initialize
                                  kClickTrackerURLKey: @"https://google.com", // required for adapter to initialize
                                  kNativeAdConfigKey: configValues,
                                  };
    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[NSMutableDictionary dictionaryWithDictionary:properties]];

    XCTAssertNotEqual(adapter.impressionTimer.requiredSecondsForImpression, configValues.impressionMinVisibleSeconds);
    XCTAssertNotEqual(adapter.impressionTimer.requiredViewVisibilityPercentage, (configValues.impressionMinVisiblePercent / 100.0));
    XCTAssertEqual(adapter.impressionTimer.requiredSecondsForImpression, 1.0);
    XCTAssertEqual(adapter.impressionTimer.requiredViewVisibilityPercentage, 0.5);
}

- (void)testImpressionRulesPropertiesDictionaryDoesNotContainConfigAfterInit {
    MPNativeAdConfigValues *configValues = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePercent:-1
                                                                                   impressionMinVisibleSeconds:-1.0];
    NSDictionary *properties = @{ kImpressionTrackerURLsKey: @[@"https://google.com"], // required for adapter to initialize
                                  kClickTrackerURLKey: @"https://google.com", // required for adapter to initialize
                                  kNativeAdConfigKey: configValues,
                                  };
    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[NSMutableDictionary dictionaryWithDictionary:properties]];
    XCTAssertNil(adapter.properties[kNativeAdConfigKey]);
}

- (void)testImpressionRulesOnlyValidPercentage {
    MPNativeAdConfigValues *configValues = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePercent:10
                                                                                   impressionMinVisibleSeconds:-1.0];
    NSDictionary *properties = @{ kImpressionTrackerURLsKey: @[@"https://google.com"], // required for adapter to initialize
                                  kClickTrackerURLKey: @"https://google.com", // required for adapter to initialize
                                  kNativeAdConfigKey: configValues,
                                  };
    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[NSMutableDictionary dictionaryWithDictionary:properties]];

    XCTAssertNotEqual(adapter.impressionTimer.requiredSecondsForImpression, configValues.impressionMinVisibleSeconds);
    CGFloat percentage = (configValues.impressionMinVisiblePercent / 100.0);
    XCTAssertEqual(adapter.impressionTimer.requiredViewVisibilityPercentage, percentage);
    XCTAssertEqual(adapter.impressionTimer.requiredSecondsForImpression, 1.0);
    CGFloat expected = 0.1;
    XCTAssertEqual(adapter.impressionTimer.requiredViewVisibilityPercentage, expected);
}

- (void)testImpressionRulesOnlyValidTimeInterval {
    MPNativeAdConfigValues *configValues = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePercent:-1
                                                                                   impressionMinVisibleSeconds:30.0];
    NSDictionary *properties = @{ kImpressionTrackerURLsKey: @[@"https://google.com"], // required for adapter to initialize
                                  kClickTrackerURLKey: @"https://google.com", // required for adapter to initialize
                                  kNativeAdConfigKey: configValues,
                                  };
    MPMoPubNativeAdAdapter *adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[NSMutableDictionary dictionaryWithDictionary:properties]];

    XCTAssertEqual(adapter.impressionTimer.requiredSecondsForImpression, configValues.impressionMinVisibleSeconds);
    XCTAssertNotEqual(adapter.impressionTimer.requiredViewVisibilityPercentage, (configValues.impressionMinVisiblePercent / 100.0));
    XCTAssertEqual(adapter.impressionTimer.requiredSecondsForImpression, 30.0);
    XCTAssertEqual(adapter.impressionTimer.requiredViewVisibilityPercentage, 0.5);
}

@end
