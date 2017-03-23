//
//  MPRewardedVideoAdManagerTests.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPAdConfiguration.h"
#import "MPRewardedVideoAdManager.h"
#import "MPRewardedVideoAdManager+Testing.h"
#import "MPRewardedVideoDelegateHandler.h"
#import "MPRewardedVideoReward.h"

static NSString * const kTestAdUnitId = @"967f82c7-c059-4ae8-8cb6-41c34265b1ef";
static const NSTimeInterval kTestTimeout   = 2; // seconds

@interface MPRewardedVideoAdManagerTests : XCTestCase

@end

@implementation MPRewardedVideoAdManagerTests

- (void)testRewardedSingleCurrencyPresentationSuccess {
    // Setup rewarded ad configuration
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameHeaderKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountHeaderKey: @"3",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPRewardedVideoReward * rewardForUser = nil;
    MPRewardedVideoDelegateHandler * delegateHandler = [MPRewardedVideoDelegateHandler new];
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
        [expectation fulfill];
    };

    MPRewardedVideoAdManager * rewardedAd = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:kTestAdUnitId delegate:delegateHandler];
    [rewardedAd loadWithConfiguration:config];
    [rewardedAd presentRewardedVideoAdFromViewController:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(rewardForUser);
    XCTAssert([rewardForUser.currencyType isEqualToString:@"Diamonds"]);
    XCTAssert(rewardForUser.amount.integerValue == 3);
}

- (void)testRewardedSingleItemInMultiCurrencyPresentationSuccess {
    // {
    //   "rewards": [
    //     { "name": "Coins", "amount": 8 }
    //   ]
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesHeaderKey: @"{ \"rewards\": [ { \"name\": \"Coins\", \"amount\": 8 } ] }" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPRewardedVideoReward * rewardForUser = nil;
    MPRewardedVideoDelegateHandler * delegateHandler = [MPRewardedVideoDelegateHandler new];
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
        [expectation fulfill];
    };

    MPRewardedVideoAdManager * rewardedAd = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:kTestAdUnitId delegate:delegateHandler];
    [rewardedAd loadWithConfiguration:config];
    [rewardedAd presentRewardedVideoAdFromViewController:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(rewardForUser);
    XCTAssert([rewardForUser.currencyType isEqualToString:@"Coins"]);
    XCTAssert(rewardForUser.amount.integerValue == 8);
}

- (void)testRewardedMultiCurrencyPresentationSuccess {
    // {
    //   "rewards": [
    //     { "name": "Coins", "amount": 8 },
    //     { "name": "Diamonds", "amount": 1 },
    //     { "name": "Energy", "amount": 20 }
    //   ]
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesHeaderKey: @"{ \"rewards\": [ { \"name\": \"Coins\", \"amount\": 8 }, { \"name\": \"Diamonds\", \"amount\": 1 }, { \"name\": \"Energy\", \"amount\": 20 } ] }" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPRewardedVideoReward * rewardForUser = nil;
    MPRewardedVideoDelegateHandler * delegateHandler = [MPRewardedVideoDelegateHandler new];
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
        [expectation fulfill];
    };

    MPRewardedVideoAdManager * rewardedAd = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:kTestAdUnitId delegate:delegateHandler];
    [rewardedAd loadWithConfiguration:config];
    [rewardedAd presentRewardedVideoAdFromViewController:nil withReward:rewardedAd.availableRewards[1]];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(rewardForUser);
    XCTAssert([rewardForUser.currencyType isEqualToString:@"Diamonds"]);
    XCTAssert(rewardForUser.amount.integerValue == 1);
}

- (void)testRewardedMultiCurrencyPresentationAutoSelectionFailure {
    // {
    //   "rewards": [
    //     { "name": "Coins", "amount": 8 },
    //     { "name": "Diamonds", "amount": 1 },
    //     { "name": "Energy", "amount": 20 }
    //   ]
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesHeaderKey: @"{ \"rewards\": [ { \"name\": \"Coins\", \"amount\": 8 }, { \"name\": \"Diamonds\", \"amount\": 1 }, { \"name\": \"Energy\", \"amount\": 20 } ] }" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPRewardedVideoReward * rewardForUser = nil;
    __block BOOL didFail = NO;
    MPRewardedVideoDelegateHandler * delegateHandler = [MPRewardedVideoDelegateHandler new];
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
        didFail = NO;
        [expectation fulfill];
    };

    delegateHandler.didFailToPlayAd = ^() {
        rewardForUser = nil;
        didFail = YES;
        [expectation fulfill];
    };

    MPRewardedVideoAdManager * rewardedAd = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:kTestAdUnitId delegate:delegateHandler];
    [rewardedAd loadWithConfiguration:config];
    [rewardedAd presentRewardedVideoAdFromViewController:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNil(rewardForUser);
    XCTAssertTrue(didFail);
}

- (void)testRewardedMultiCurrencyPresentationNilParameterAutoSelectionFailure {
    // {
    //   "rewards": [
    //     { "name": "Coins", "amount": 8 },
    //     { "name": "Diamonds", "amount": 1 },
    //     { "name": "Energy", "amount": 20 }
    //   ]
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesHeaderKey: @"{ \"rewards\": [ { \"name\": \"Coins\", \"amount\": 8 }, { \"name\": \"Diamonds\", \"amount\": 1 }, { \"name\": \"Energy\", \"amount\": 20 } ] }" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPRewardedVideoReward * rewardForUser = nil;
    __block BOOL didFail = NO;
    MPRewardedVideoDelegateHandler * delegateHandler = [MPRewardedVideoDelegateHandler new];
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
        didFail = NO;
        [expectation fulfill];
    };

    delegateHandler.didFailToPlayAd = ^() {
        rewardForUser = nil;
        didFail = YES;
        [expectation fulfill];
    };

    MPRewardedVideoAdManager * rewardedAd = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:kTestAdUnitId delegate:delegateHandler];
    [rewardedAd loadWithConfiguration:config];
    [rewardedAd presentRewardedVideoAdFromViewController:nil withReward:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNil(rewardForUser);
    XCTAssertTrue(didFail);
}

- (void)testRewardedMultiCurrencyPresentationUnknownSelectionFail {
    // {
    //   "rewards": [
    //     { "name": "Coins", "amount": 8 },
    //     { "name": "Diamonds", "amount": 1 },
    //     { "name": "Energy", "amount": 20 }
    //   ]
    // }
    NSDictionary * headers = @{ kRewardedCurrenciesHeaderKey: @"{ \"rewards\": [ { \"name\": \"Coins\", \"amount\": 8 }, { \"name\": \"Diamonds\", \"amount\": 1 }, { \"name\": \"Energy\", \"amount\": 20 } ] }" };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPRewardedVideoReward * rewardForUser = nil;
    __block BOOL didFail = NO;
    MPRewardedVideoDelegateHandler * delegateHandler = [MPRewardedVideoDelegateHandler new];
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
        didFail = NO;
        [expectation fulfill];
    };

    delegateHandler.didFailToPlayAd = ^() {
        rewardForUser = nil;
        didFail = YES;
        [expectation fulfill];
    };

    // Create a malicious reward
    MPRewardedVideoReward * badReward = [[MPRewardedVideoReward alloc] initWithCurrencyType:@"$$$" amount:@(100)];

    MPRewardedVideoAdManager * rewardedAd = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:kTestAdUnitId delegate:delegateHandler];
    [rewardedAd loadWithConfiguration:config];
    [rewardedAd presentRewardedVideoAdFromViewController:nil withReward:badReward];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNil(rewardForUser);
    XCTAssertTrue(didFail);
}

@end
