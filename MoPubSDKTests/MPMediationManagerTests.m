//
//  MPMediationManagerTests.m
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MoPub.h"
#import "MPMediationManager.h"
#import "MPStubCustomEvent.h"
#import "MPStubMediatedNetwork.h"

static const NSTimeInterval kTestTimeout = 2; // seconds

@interface MPMediationManagerTests : XCTestCase

@end

@implementation MPMediationManagerTests

- (void)setUp {
    [super setUp];
    [MPMediationManager.sharedManager clearCache];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Network SDK Initialization

- (void)testNetworkSDKInitializationNotInCache {
    [MPStubCustomEvent resetInitialization];
    XCTAssertFalse([MPStubCustomEvent isInitialized]);

    // Initialize
    XCTestExpectation * expectation = [self expectationWithDescription:@"Mediation initialization"];
    [MPMediationManager.sharedManager initializeMediatedNetworks:@[MPStubCustomEvent.class] completion:^(NSError * _Nullable error) {
        [expectation fulfill];
    }];

    // Wait for SDKs to initialize
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertFalse([MPStubCustomEvent isInitialized]);
}

- (void)testNetworkSDKInitializationSuccess {
    [MPStubCustomEvent resetInitialization];
    XCTAssertFalse([MPStubCustomEvent isInitialized]);

    // Set an entry in the cache to indicate that it was previously initialized on-demand
    [MPMediationManager.sharedManager setCachedInitializationParameters:@{ @"poop": @"poop" } forNetwork:MPStubCustomEvent.class];

    // Initialize
    XCTestExpectation * expectation = [self expectationWithDescription:@"Mediation initialization"];
    [MPMediationManager.sharedManager initializeMediatedNetworks:@[MPStubCustomEvent.class] completion:^(NSError * _Nullable error) {
        [expectation fulfill];
    }];

    // Wait for SDKs to initialize
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue([MPStubCustomEvent isInitialized]);
}

- (void)testNoNetworkSDKInitialization {
    [MPStubCustomEvent resetInitialization];
    XCTAssertFalse([MPStubCustomEvent isInitialized]);

    XCTestExpectation * expectation = [self expectationWithDescription:@"Mediation initialization"];
    [MPMediationManager.sharedManager initializeMediatedNetworks:nil completion:^(NSError * _Nullable error) {
        [expectation fulfill];
    }];

    // Wait for SDKs to initialize
    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertFalse([MPStubCustomEvent isInitialized]);
}

#pragma mark - Caching

- (void)testSetCacheSuccess {
    NSDictionary * params = @{ @"appId": @"adcolony_app_id",
                               @"zones": @[@"zone 1", @"zone 2"],
                               };

    [MPMediationManager.sharedManager setCachedInitializationParameters:params forNetwork:MPStubMediatedNetwork.class];

    NSDictionary * cachedParams = [MPMediationManager.sharedManager cachedInitializationParametersForNetwork:MPStubMediatedNetwork.class];
    XCTAssertNotNil(cachedParams);

    NSString * appId = cachedParams[@"appId"];
    XCTAssertNotNil(appId);
    XCTAssertTrue([appId isEqualToString:@"adcolony_app_id"]);

    NSArray * zones = cachedParams[@"zones"];
    XCTAssertNotNil(zones);
    XCTAssertTrue(zones.count == 2);
    XCTAssertTrue([zones[0] isEqualToString:@"zone 1"]);
    XCTAssertTrue([zones[1] isEqualToString:@"zone 2"]);
}

- (void)testSetCacheNoNetwork {
    NSDictionary * params = @{ @"appId": @"admob_app_id" };

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    // Intentially set the explicitly marked `nonnull` property to `nil` to
    // simulate an error state.
    [MPMediationManager.sharedManager setCachedInitializationParameters:params forNetwork:nil];
#pragma clang diagnostic pop

    NSDictionary * cachedParams = [MPMediationManager.sharedManager cachedInitializationParametersForNetwork:MPStubMediatedNetwork.class];
    XCTAssertNil(cachedParams);
}

- (void)testSetCacheNoParams {
    [MPMediationManager.sharedManager setCachedInitializationParameters:nil forNetwork:MPStubMediatedNetwork.class];

    NSDictionary * cachedParams = [MPMediationManager.sharedManager cachedInitializationParametersForNetwork:MPStubMediatedNetwork.class];
    XCTAssertNil(cachedParams);
}

- (void)testClearCache {
    NSDictionary * params = @{ @"appId": @"tapjpy_app_id" };

    [MPMediationManager.sharedManager setCachedInitializationParameters:params forNetwork:MPStubMediatedNetwork.class];

    NSDictionary * cachedParams = [MPMediationManager.sharedManager cachedInitializationParametersForNetwork:MPStubMediatedNetwork.class];
    XCTAssertNotNil(cachedParams);

    [MPMediationManager.sharedManager clearCache];

    cachedParams = [MPMediationManager.sharedManager cachedInitializationParametersForNetwork:MPStubMediatedNetwork.class];
    XCTAssertNil(cachedParams);
}

- (void)testSetCacheFromSubclassSuccess {
    NSDictionary * params = @{ @"appId": @"vungle_app_id" };

    MPStubCustomEvent * testCustomEvent = [MPStubCustomEvent new];

    [testCustomEvent setCachedInitializationParameters:params];

    NSDictionary * cachedParams = [testCustomEvent cachedInitializationParameters];
    XCTAssertNotNil(cachedParams);

    NSString * appId = cachedParams[@"appId"];
    XCTAssertNotNil(appId);
    XCTAssertTrue([appId isEqualToString:@"vungle_app_id"]);
}

@end
