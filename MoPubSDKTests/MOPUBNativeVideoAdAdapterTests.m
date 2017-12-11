//
//  MOPUBNativeVideoAdAdapterTests.m
//  MoPubSDKTests
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MOPUBNativeVideoAdAdapter+Testing.h"
#import "MPAdImpressionTimer+Testing.h"
#import "MPNativeAdConstants.h"
#import "MOPUBNativeVideoAdConfigValues.h"

@interface MOPUBNativeVideoAdAdapterTests : XCTestCase

@end

@implementation MOPUBNativeVideoAdAdapterTests

#pragma mark - Testing impression tracking header rules

- (void)testValidPixelsAndTime {
    MOPUBNativeVideoAdConfigValues *config = [[MOPUBNativeVideoAdConfigValues alloc] initWithPlayVisiblePercent:50
                                                                                            pauseVisiblePercent:50
                                                                                     impressionMinVisiblePixels:1
                                                                                    impressionMinVisiblePercent:-1
                                                                                    impressionMinVisibleSeconds:30
                                                                                               maxBufferingTime:10
                                                                                                       trackers:nil];
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                      kAdIconImageKey: @"",
                                                                                      kAdMainImageKey: @"",
                                                                                      kAdTextKey: @"",
                                                                                      kAdTitleKey: @"",
                                                                                      kAdCTATextKey: @"",
                                                                                      kVASTVideoKey: @"",
                                                                                      kImpressionTrackerURLsKey: @[@"https://google.com"],
                                                                                      kClickTrackerURLKey: @[@"https://google.com"],
                                                                                      kNativeAdConfigKey: config,
                                                                                      }];
    MOPUBNativeVideoAdAdapter *adapter = [[MOPUBNativeVideoAdAdapter alloc] initWithAdProperties:properties];
    [adapter willAttachToView:[[UIView alloc] init]];

    XCTAssertEqual(config.impressionMinVisiblePixels, adapter.impressionTimer.pixelsRequiredForViewVisibility);
    XCTAssertNotEqual(config.impressionMinVisiblePercent * 0.01f, adapter.impressionTimer.percentageRequiredForViewVisibility);
    XCTAssertEqual(config.impressionMinVisibleSeconds, adapter.impressionTimer.requiredSecondsForImpression);
}

- (void)testValidPixelsTakesPriorityOverPercentWithValidTime {
    MOPUBNativeVideoAdConfigValues *config = [[MOPUBNativeVideoAdConfigValues alloc] initWithPlayVisiblePercent:50
                                                                                            pauseVisiblePercent:50
                                                                                     impressionMinVisiblePixels:1
                                                                                    impressionMinVisiblePercent:50
                                                                                    impressionMinVisibleSeconds:30
                                                                                               maxBufferingTime:10
                                                                                                       trackers:nil];
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                      kAdIconImageKey: @"",
                                                                                      kAdMainImageKey: @"",
                                                                                      kAdTextKey: @"",
                                                                                      kAdTitleKey: @"",
                                                                                      kAdCTATextKey: @"",
                                                                                      kVASTVideoKey: @"",
                                                                                      kImpressionTrackerURLsKey: @[@"https://google.com"],
                                                                                      kClickTrackerURLKey: @[@"https://google.com"],
                                                                                      kNativeAdConfigKey: config,
                                                                                      }];
    MOPUBNativeVideoAdAdapter *adapter = [[MOPUBNativeVideoAdAdapter alloc] initWithAdProperties:properties];
    [adapter willAttachToView:[[UIView alloc] init]];

    XCTAssertEqual(config.impressionMinVisiblePixels, adapter.impressionTimer.pixelsRequiredForViewVisibility);
    XCTAssertNotEqual(config.impressionMinVisiblePercent * 0.01f, adapter.impressionTimer.percentageRequiredForViewVisibility);
    XCTAssertEqual(config.impressionMinVisibleSeconds, adapter.impressionTimer.requiredSecondsForImpression);
}

- (void)testValidPercentAndTime {
    MOPUBNativeVideoAdConfigValues *config = [[MOPUBNativeVideoAdConfigValues alloc] initWithPlayVisiblePercent:50
                                                                                            pauseVisiblePercent:50
                                                                                     impressionMinVisiblePixels:-1
                                                                                    impressionMinVisiblePercent:50
                                                                                    impressionMinVisibleSeconds:30
                                                                                               maxBufferingTime:10
                                                                                                       trackers:nil];
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                      kAdIconImageKey: @"",
                                                                                      kAdMainImageKey: @"",
                                                                                      kAdTextKey: @"",
                                                                                      kAdTitleKey: @"",
                                                                                      kAdCTATextKey: @"",
                                                                                      kVASTVideoKey: @"",
                                                                                      kImpressionTrackerURLsKey: @[@"https://google.com"],
                                                                                      kClickTrackerURLKey: @[@"https://google.com"],
                                                                                      kNativeAdConfigKey: config,
                                                                                      }];
    MOPUBNativeVideoAdAdapter *adapter = [[MOPUBNativeVideoAdAdapter alloc] initWithAdProperties:properties];
    [adapter willAttachToView:[[UIView alloc] init]];

    XCTAssertNotEqual(config.impressionMinVisiblePixels, adapter.impressionTimer.pixelsRequiredForViewVisibility);
    XCTAssertEqual(config.impressionMinVisiblePercent * 0.01f, adapter.impressionTimer.percentageRequiredForViewVisibility);
    XCTAssertEqual(config.impressionMinVisibleSeconds, adapter.impressionTimer.requiredSecondsForImpression);
}

@end
