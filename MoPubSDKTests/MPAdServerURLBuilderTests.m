//
//  MPAdServerURLBuilderTests.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPAdServerURLBuilder+Testing.h"
#import "MPAdvancedBiddingManager+Testing.h"
#import "MPAPIEndpoints.h"
#import "MPConsentManager.h"
#import "MPViewabilityTracker.h"
#import "NSURLComponents+Testing.h"
#import "MPStubAdvancedBidder.h"
#import "NSString+MPConsentStatus.h"

static NSString *const kTestAdUnitId = @"";
static NSString *const kTestKeywords = @"";
static NSTimeInterval const kTestTimeout = 4;
static NSString * const kGDPRAppliesStorageKey                   = @"com.mopub.mopub-ios-sdk.gdpr.applies";
static NSString * const kConsentedIabVendorListStorageKey        = @"com.mopub.mopub-ios-sdk.consented.iab.vendor.list";
static NSString * const kConsentedPrivacyPolicyVersionStorageKey = @"com.mopub.mopub-ios-sdk.consented.privacy.policy.version";
static NSString * const kConsentedVendorListVersionStorageKey    = @"com.mopub.mopub-ios-sdk.consented.vendor.list.version";

@interface MPAdServerURLBuilderTests : XCTestCase

@end

@implementation MPAdServerURLBuilderTests

- (void)setUp {
    // Reset viewability
    [MPViewabilityTracker initialize];

    NSUserDefaults * defaults = NSUserDefaults.standardUserDefaults;
    [defaults setInteger:MPBoolYes forKey:kGDPRAppliesStorageKey];
    [defaults setObject:nil forKey:kConsentedIabVendorListStorageKey];
    [defaults setObject:nil forKey:kConsentedPrivacyPolicyVersionStorageKey];
    [defaults setObject:nil forKey:kConsentedVendorListVersionStorageKey];
    [defaults synchronize];
}

#pragma mark - Viewability

- (void)testViewabilityQueryParameterPresent {
    // By default, IAS should be enabled
    NSURL * url = [MPAdServerURLBuilder URLWithAdUnitID:kTestAdUnitId keywords:kTestKeywords userDataKeywords:nil location:nil];
    NSURLComponents * urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];

    NSString * viewabilityQueryParamValue = [urlComponents valueForQueryParameter:@"vv"];
    XCTAssertNotNil(viewabilityQueryParamValue);
    XCTAssertTrue([viewabilityQueryParamValue isEqualToString:@"1"]);
}

- (void)testViewabilityDisabled {
    // By default, IAS should be enabled so we should disable all vendors
    [MPViewabilityTracker disableViewability:(MPViewabilityOptionIAS | MPViewabilityOptionMoat)];

    NSURL * url = [MPAdServerURLBuilder URLWithAdUnitID:kTestAdUnitId keywords:kTestKeywords userDataKeywords:nil location:nil];
    NSURLComponents * urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];

    NSString * viewabilityQueryParamValue = [urlComponents valueForQueryParameter:@"vv"];
    XCTAssertNotNil(viewabilityQueryParamValue);
    XCTAssertTrue([viewabilityQueryParamValue isEqualToString:@"0"]);
}

#pragma mark - Advanced Bidding

- (void)testAdvancedBiddingNotInitialized {
    MPAdvancedBiddingManager.sharedManager.bidders = [NSMutableDictionary dictionary];
    MPAdvancedBiddingManager.sharedManager.advancedBiddingEnabled = YES;
    NSString * queryParam = [MPAdServerURLBuilder queryParameterForAdvancedBidding];

    XCTAssertNil(queryParam);
}

- (void)testAdvancedBiddingDisabled {
    MPAdvancedBiddingManager.sharedManager.bidders = [NSMutableDictionary dictionary];
    MPAdvancedBiddingManager.sharedManager.advancedBiddingEnabled = NO;
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect advanced bidders to initialize"];

    [MPAdvancedBiddingManager.sharedManager initializeBidders:@[MPStubAdvancedBidder.class] complete:^{
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    NSString * queryParam = [MPAdServerURLBuilder queryParameterForAdvancedBidding];

    XCTAssertNil(queryParam);
}

#pragma mark - Consent

- (void)testConsentStatusAdQueryParam {
    NSString * consentStatus = [NSString stringFromConsentStatus:MPConsentManager.sharedManager.currentStatus];
    XCTAssertNotNil(consentStatus);

    NSString * expectedQueryParam = [NSString stringWithFormat:@"&current_consent_status=%@&gdpr_applies=1", consentStatus];
    NSString * queryParam = [MPAdServerURLBuilder queryParameterForConsent];
    XCTAssertNotNil(queryParam);
    XCTAssert([queryParam isEqualToString:expectedQueryParam]);
}

- (void)testConsentStatusInAdRequest {
    NSString * consentStatus = [NSString stringFromConsentStatus:MPConsentManager.sharedManager.currentStatus];
    XCTAssertNotNil(consentStatus);

    NSString * expectedQueryParam = [NSString stringWithFormat:@"&current_consent_status=%@&gdpr_applies=1", consentStatus];
    NSURL * request = [MPAdServerURLBuilder URLWithAdUnitID:@"1234" keywords:nil userDataKeywords:nil location:nil];
    XCTAssertNotNil(request);
    XCTAssert([request.query containsString:expectedQueryParam]);
}

- (void)testQueryParameterEncodingSuccess {
    NSString * param = [MPAdServerURLBuilder queryItemForKey:@"a" value:@"i'm extra!"];
    XCTAssert([param isEqualToString:@"a=i%27m%20extra%21"]);
}

#pragma mark - Open Endpoint

- (void)testExpectedQueryParamsSessionTracking {
    NSString *URLString = [MPAdServerURLBuilder sessionTrackingURL].absoluteString;

    // Check for session tracking parameter
    XCTAssert([URLString containsString:@"st=1"]);

    // Check for IDFA
    XCTAssert([URLString containsString:@"udid="]);

    // Check for SDK version
    XCTAssert([URLString containsString:@"nv="]);

    // Check for current consent status
    XCTAssert([URLString containsString:@"current_consent_status="]);
}

- (void)testExpectedQueryParamsConversionTracking {
    NSString *appID = @"0123456789";
    NSString *URLString = [MPAdServerURLBuilder conversionTrackingURLForAppID:appID].absoluteString;

    // Check for lack of session tracking parameter
    XCTAssertFalse([URLString containsString:@"st=1"]);

    // Check for IDFA
    XCTAssert([URLString containsString:@"udid="]);

    // Check for ID
    NSString *idParamString = [NSString stringWithFormat:@"id=%@", appID];
    XCTAssert([URLString containsString:idParamString]);

    // Check for SDK version
    XCTAssert([URLString containsString:@"nv="]);

    // Check for current consent status
    XCTAssert([URLString containsString:@"current_consent_status="]);
}

@end
