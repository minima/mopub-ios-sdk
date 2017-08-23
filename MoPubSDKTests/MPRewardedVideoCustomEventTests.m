//
//  MPRewardedVideoCustomEventTests.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPRewardedVideoNetwork.h"
#import "MPRewardedVideoCustomEvent+Caching.h"
#import "MPStubCustomEvent.h"

@interface MPRewardedVideoCustomEventTests : XCTestCase

@end

@implementation MPRewardedVideoCustomEventTests

- (void)setUp {
    [super setUp];

    // Clear any cached network SDK initialization parameters
    [MPRewardedVideoCustomEvent clearCache];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Caching

- (void)testSetCacheSuccess {
    NSDictionary * params = @{ @"appId": @"adcolony_app_id",
                               @"zones": @[@"zone 1", @"zone 2"],
                            };

    [MPRewardedVideoCustomEvent setCachedInitializationParameters:params forNetwork:MPRewardedVideoNetwork.AdColony];

    NSDictionary * cachedParams = [MPRewardedVideoCustomEvent cachedInitializationParametersForNetwork:MPRewardedVideoNetwork.AdColony];
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

    [MPRewardedVideoCustomEvent setCachedInitializationParameters:params forNetwork:@""];

    NSDictionary * cachedParams = [MPRewardedVideoCustomEvent cachedInitializationParametersForNetwork:MPRewardedVideoNetwork.AdMob];
    XCTAssertNil(cachedParams);
}

- (void)testSetCacheNoParams {
    [MPRewardedVideoCustomEvent setCachedInitializationParameters:nil forNetwork:MPRewardedVideoNetwork.Chartboost];

    NSDictionary * cachedParams = [MPRewardedVideoCustomEvent cachedInitializationParametersForNetwork:MPRewardedVideoNetwork.Chartboost];
    XCTAssertNil(cachedParams);
}

- (void)testClearCache {
    NSDictionary * params = @{ @"appId": @"tapjpy_app_id" };

    [MPRewardedVideoCustomEvent setCachedInitializationParameters:params forNetwork:MPRewardedVideoNetwork.Tapjoy];

    NSDictionary * cachedParams = [MPRewardedVideoCustomEvent cachedInitializationParametersForNetwork:MPRewardedVideoNetwork.Tapjoy];
    XCTAssertNotNil(cachedParams);

    [MPRewardedVideoCustomEvent clearCache];

    cachedParams = [MPRewardedVideoCustomEvent cachedInitializationParametersForNetwork:MPRewardedVideoNetwork.Tapjoy];
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
