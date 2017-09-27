//
//  MPNativeAdConfigValuesTests.m
//  MoPubSDKTests
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPNativeAdConfigValues.h"

@interface MPNativeAdConfigValuesTests : XCTestCase

@end

@implementation MPNativeAdConfigValuesTests

- (void)testValidationSuccessNormal {
    // 50% for 1 second
    MPNativeAdConfigValues *config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePercent:50 impressionMinVisibleSeconds:1];
    XCTAssert(config.isImpressionMinVisiblePercentValid);
    XCTAssert(config.isImpressionMinVisibleSecondsValid);
}

- (void)testValidationSuccessEdges {
    MPNativeAdConfigValues *config;
    
    // 100% for 0.01 seconds
    config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePercent:100 impressionMinVisibleSeconds:0.01];
    XCTAssert(config.isImpressionMinVisiblePercentValid);
    XCTAssert(config.isImpressionMinVisibleSecondsValid);
    
    // 0% for 0.01 seconds
    config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePercent:0 impressionMinVisibleSeconds:0.01];
    XCTAssert(config.isImpressionMinVisiblePercentValid);
    XCTAssert(config.isImpressionMinVisibleSecondsValid);
}

- (void)testValidationFailure {
    MPNativeAdConfigValues *config;
    
    // 50% for 0 seconds
    config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePercent:50 impressionMinVisibleSeconds:0];
    XCTAssert(config.isImpressionMinVisiblePercentValid);
    XCTAssertFalse(config.isImpressionMinVisibleSecondsValid);
    
    // 50% for -1 seconds
    config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePercent:50 impressionMinVisibleSeconds:-1];
    XCTAssert(config.isImpressionMinVisiblePercentValid);
    XCTAssertFalse(config.isImpressionMinVisibleSecondsValid);
    
    // 101% for 1 second
    config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePercent:101 impressionMinVisibleSeconds:1];
    XCTAssertFalse(config.isImpressionMinVisiblePercentValid);
    XCTAssert(config.isImpressionMinVisibleSecondsValid);
    
    // -1% for 1 second
    config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePercent:-1 impressionMinVisibleSeconds:1];
    XCTAssertFalse(config.isImpressionMinVisiblePercentValid);
    XCTAssert(config.isImpressionMinVisibleSecondsValid);
    
    // -1% for -1 seconds
    config = [[MPNativeAdConfigValues alloc] initWithImpressionMinVisiblePercent:-1 impressionMinVisibleSeconds:-1];
    XCTAssertFalse(config.isImpressionMinVisiblePercentValid);
    XCTAssertFalse(config.isImpressionMinVisibleSecondsValid);
}

@end
