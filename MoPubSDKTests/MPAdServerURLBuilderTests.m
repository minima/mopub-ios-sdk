//
//  MPAdServerURLBuilderTests.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPAdServerURLBuilder.h"
#import "MPAPIEndpoints.h"
#import "MPViewabilityTracker.h"
#import "NSURLComponents+Testing.h"

static NSString *const kTestAdUnitId = @"";
static NSString *const kTestKeywords = @"";

@interface MPAdServerURLBuilderTests : XCTestCase

@end

@implementation MPAdServerURLBuilderTests

- (void)setUp {
    // Reset viewability
    [MPViewabilityTracker initialize];
}

#pragma mark - Viewability

- (void)testViewabilityQueryParameterPresent {
    // By default, IAS should be enabled
    NSURL * url = [MPAdServerURLBuilder URLWithAdUnitID:kTestAdUnitId keywords:kTestKeywords location:nil testing:NO];
    NSURLComponents * urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:MOPUB_BASE_HOSTNAME];

    NSString * viewabilityQueryParamValue = [urlComponents valueForQueryParameter:@"vv"];
    XCTAssertNotNil(viewabilityQueryParamValue);
    XCTAssertTrue([viewabilityQueryParamValue isEqualToString:@"1"]);
}

- (void)testViewabilityDisabled {
    // By default, IAS should be enabled so we should disable all vendors
    [MPViewabilityTracker disableViewability:(MPViewabilityOptionIAS | MPViewabilityOptionMoat)];

    NSURL * url = [MPAdServerURLBuilder URLWithAdUnitID:kTestAdUnitId keywords:kTestKeywords location:nil testing:NO];
    NSURLComponents * urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:MOPUB_BASE_HOSTNAME];

    NSString * viewabilityQueryParamValue = [urlComponents valueForQueryParameter:@"vv"];
    XCTAssertNotNil(viewabilityQueryParamValue);
    XCTAssertTrue([viewabilityQueryParamValue isEqualToString:@"0"]);
}

@end
