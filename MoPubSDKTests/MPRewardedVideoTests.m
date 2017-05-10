//
//  MPRewardedVideoTests.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPAdConfiguration.h"
#import "MoPub.h"
#import "MPRewardedVideo.h"
#import "MPRewardedVideo+Testing.h"
#import "MPRewardedVideoDelegateHandler.h"
#import "NSURLComponents+Testing.h"

static NSString * const kTestAdUnitId    = @"967f82c7-c059-4ae8-8cb6-41c34265b1ef";
static const NSTimeInterval kTestTimeout = 2; // seconds

// delegateHandler needs to be declared static because if it is a property, it
// will be nil'ed out at the end of a test.
static MPRewardedVideoDelegateHandler * delegateHandler = nil;

@interface MPRewardedVideoTests : XCTestCase
@end

@implementation MPRewardedVideoTests

- (void)setUp {
    [super setUp];

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        delegateHandler = [MPRewardedVideoDelegateHandler new];
        [[MoPub sharedInstance] initializeRewardedVideoWithGlobalMediationSettings:nil delegate:delegateHandler];
    });
}

- (void)tearDown {
    [super tearDown];
    [delegateHandler resetHandlers];
}

#pragma mark - Single Currency

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
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
        [expectation fulfill];
    };

    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:kTestAdUnitId withTestConfiguration:config];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:kTestAdUnitId fromViewController:[UIViewController new]];

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
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
        [expectation fulfill];
    };

    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:kTestAdUnitId withTestConfiguration:config];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:kTestAdUnitId fromViewController:[UIViewController new]];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(rewardForUser);
    XCTAssert([rewardForUser.currencyType isEqualToString:@"Coins"]);
    XCTAssert(rewardForUser.amount.integerValue == 8);
}

- (void)testRewardedSingleItemInMultiCurrencyPresentationS2SSuccess {
    // {
    //   "rewards": [
    //     { "name": "Coins", "amount": 8 }
    //   ]
    // }
    NSDictionary * headers = @{ kRewardedVideoCompletionUrlHeaderKey: @"https://test.com?verifier=123",
                                kRewardedCurrenciesHeaderKey: @"{ \"rewards\": [ { \"name\": \"Coins\", \"amount\": 8 } ] }"
                              };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPRewardedVideoReward * rewardForUser = nil;
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
    };

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
        [expectation fulfill];
    };

    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:kTestAdUnitId withTestConfiguration:config];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:kTestAdUnitId fromViewController:[UIViewController new]];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(rewardForUser);
    XCTAssertNotNil(s2sUrl);

    NSURLComponents * s2sUrlComponents = [NSURLComponents componentsWithURL:s2sUrl resolvingAgainstBaseURL:NO];
    XCTAssert([[s2sUrlComponents valueForQueryParameter:@"rcn"] isEqualToString:@"Coins"]);
    XCTAssert([[s2sUrlComponents valueForQueryParameter:@"rca"] isEqualToString:@"8"]);
}

#pragma mark - Multiple Currency

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
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
        [expectation fulfill];
    };

    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:kTestAdUnitId withTestConfiguration:config];
    NSArray * availableRewards = [MPRewardedVideo availableRewardsForAdUnitID:kTestAdUnitId];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:kTestAdUnitId fromViewController:[UIViewController new] withReward:availableRewards[1]];

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

    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:kTestAdUnitId withTestConfiguration:config];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:kTestAdUnitId fromViewController:[UIViewController new]];

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

    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:kTestAdUnitId withTestConfiguration:config];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:kTestAdUnitId fromViewController:[UIViewController new] withReward:nil];

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

    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:kTestAdUnitId withTestConfiguration:config];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:kTestAdUnitId fromViewController:[UIViewController new] withReward:badReward];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNil(rewardForUser);
    XCTAssertTrue(didFail);
}

- (void)testRewardedMultiCurrencyS2SPresentationSuccess {
    // {
    //   "rewards": [
    //     { "name": "Coins", "amount": 8 },
    //     { "name": "Diamonds", "amount": 1 },
    //     { "name": "Energy", "amount": 20 }
    //   ]
    // }
    NSDictionary * headers = @{ kRewardedVideoCompletionUrlHeaderKey: @"https://test.com?verifier=123",
                                kRewardedCurrenciesHeaderKey: @"{ \"rewards\": [ { \"name\": \"Coins\", \"amount\": 8 }, { \"name\": \"Diamonds\", \"amount\": 1 }, { \"name\": \"Energy\", \"amount\": 20 } ] }"
                              };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPRewardedVideoReward * rewardForUser = nil;
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
    };

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
        [expectation fulfill];
    };

    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:kTestAdUnitId withTestConfiguration:config];
    NSArray * availableRewards = [MPRewardedVideo availableRewardsForAdUnitID:kTestAdUnitId];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:kTestAdUnitId fromViewController:[UIViewController new] withReward:availableRewards[1]];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(rewardForUser);
    XCTAssertNotNil(s2sUrl);

    NSURLComponents * s2sUrlComponents = [NSURLComponents componentsWithURL:s2sUrl resolvingAgainstBaseURL:NO];
    XCTAssert([[s2sUrlComponents valueForQueryParameter:@"rcn"] isEqualToString:@"Diamonds"]);
    XCTAssert([[s2sUrlComponents valueForQueryParameter:@"rca"] isEqualToString:@"1"]);
}

- (void)testRewardedS2SNoRewardSpecified {
    NSDictionary * headers = @{ kRewardedVideoCompletionUrlHeaderKey: @"https://test.com?verifier=123",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the reward event.
    __block MPRewardedVideoReward * rewardForUser = nil;
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
    };

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
        [expectation fulfill];
    };

    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:kTestAdUnitId withTestConfiguration:config];
    NSArray * availableRewards = [MPRewardedVideo availableRewardsForAdUnitID:kTestAdUnitId];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:kTestAdUnitId fromViewController:[UIViewController new] withReward:availableRewards[0]];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(rewardForUser);
    XCTAssertNotNil(s2sUrl);

    NSURLComponents * s2sUrlComponents = [NSURLComponents componentsWithURL:s2sUrl resolvingAgainstBaseURL:NO];
    XCTAssertFalse([s2sUrlComponents hasQueryParameter:@"rcn"]);
    XCTAssertFalse([s2sUrlComponents valueForQueryParameter:@"rca"]);
}

@end
