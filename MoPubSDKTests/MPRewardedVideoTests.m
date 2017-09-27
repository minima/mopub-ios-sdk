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
#import "MPRewardedVideoAdapter+Testing.h"
#import "MPRewardedVideoDelegateHandler.h"
#import "MPStubCustomEvent.h"
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

#pragma mark - Network SDK Initialization

- (void)testNetworkSDKInitializationSuccess {
    [MPStubCustomEvent resetInitialization];
    XCTAssertFalse([MPStubCustomEvent isInitialized]);

    [MPRewardedVideo initializeWithOrder:@[@"MPStubCustomEvent"]];

    // Wait for SDKs to initialize
    XCTestExpectation * expectation = [self expectationWithDescription:@"Expect timer to fire"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((kTestTimeout / 2.0) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue([MPStubCustomEvent isInitialized]);
}

- (void)testNoNetworkSDKInitialization {
    [MPStubCustomEvent resetInitialization];
    XCTAssertFalse([MPStubCustomEvent isInitialized]);

    [MPRewardedVideo initializeWithOrder:nil];
    XCTAssertFalse([MPStubCustomEvent isInitialized]);
}

- (void)testUnknownNetworkSDKInitialization {
    [MPStubCustomEvent resetInitialization];
    XCTAssertFalse([MPStubCustomEvent isInitialized]);

    [MPRewardedVideo initializeWithOrder:@[@"badf00d"]];
    XCTAssertFalse([MPStubCustomEvent isInitialized]);
}

- (void)testIntentionallyBadNetworkSDKInitialization {
    [MPStubCustomEvent resetInitialization];
    XCTAssertFalse([MPStubCustomEvent isInitialized]);

    [MPRewardedVideo initializeWithOrder:@[@"MPRewardedVideo"]];
    XCTAssertFalse([MPStubCustomEvent isInitialized]);
}

#pragma mark - Custom Data

- (void)testCustomDataNormalDataLength {
    // Generate a custom data string that is well under 8196 characters
    NSString * customData = [@"" stringByPaddingToLength:512 withString:@"test" startingAtIndex:0];

    // Setup rewarded ad configuration
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameHeaderKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountHeaderKey: @"3",
                                kRewardedVideoCompletionUrlHeaderKey: @"https://test.com?verifier=123",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
        [expectation fulfill];
    };

    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:kTestAdUnitId withTestConfiguration:config];
    MPRewardedVideoReward * reward = [MPRewardedVideo availableRewardsForAdUnitID:kTestAdUnitId][0];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:kTestAdUnitId fromViewController:[UIViewController new] withReward:reward customData:customData];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(s2sUrl);

    NSString * encodedCustomDataQueryParam = [NSString stringWithFormat:@"rcd=%@", customData];
    XCTAssert([s2sUrl.absoluteString containsString:encodedCustomDataQueryParam]);
}

- (void)testCustomDataExcessiveDataLength {
    // Generate a custom data string that exceeds 8196 characters
    NSString * customData = [@"" stringByPaddingToLength:8200 withString:@"test" startingAtIndex:0];

    // Setup rewarded ad configuration
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameHeaderKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountHeaderKey: @"3",
                                kRewardedVideoCompletionUrlHeaderKey: @"https://test.com?verifier=123",
                              };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
        [expectation fulfill];
    };

    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:kTestAdUnitId withTestConfiguration:config];
    MPRewardedVideoReward * reward = [MPRewardedVideo availableRewardsForAdUnitID:kTestAdUnitId][0];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:kTestAdUnitId fromViewController:[UIViewController new] withReward:reward customData:customData];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(s2sUrl);

    NSString * encodedCustomDataQueryParam = [NSString stringWithFormat:@"rcd=%@", customData];
    XCTAssert([s2sUrl.absoluteString containsString:encodedCustomDataQueryParam]);
}

- (void)testCustomDataNil {
    // Setup rewarded ad configuration
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameHeaderKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountHeaderKey: @"3",
                                kRewardedVideoCompletionUrlHeaderKey: @"https://test.com?verifier=123",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
        [expectation fulfill];
    };

    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:kTestAdUnitId withTestConfiguration:config];
    MPRewardedVideoReward * reward = [MPRewardedVideo availableRewardsForAdUnitID:kTestAdUnitId][0];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:kTestAdUnitId fromViewController:[UIViewController new] withReward:reward customData:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(s2sUrl);
    XCTAssert(![s2sUrl.absoluteString containsString:@"rcd="]);
}

- (void)testCustomDataEmpty {
    // Setup rewarded ad configuration
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameHeaderKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountHeaderKey: @"3",
                                kRewardedVideoCompletionUrlHeaderKey: @"https://test.com?verifier=123",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
        [expectation fulfill];
    };

    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:kTestAdUnitId withTestConfiguration:config];
    MPRewardedVideoReward * reward = [MPRewardedVideo availableRewardsForAdUnitID:kTestAdUnitId][0];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:kTestAdUnitId fromViewController:[UIViewController new] withReward:reward customData:@""];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(s2sUrl);
    XCTAssert(![s2sUrl.absoluteString containsString:@"rcd="]);
}

- (void)testCustomDataURIEncoded {
    // Custom data in need of URI encoding
    NSString * customData = @"{ \"key\": \"some value with spaces\" }";

    // Setup rewarded ad configuration
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameHeaderKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountHeaderKey: @"3",
                                kRewardedVideoCompletionUrlHeaderKey: @"https://test.com?verifier=123",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
        [expectation fulfill];
    };

    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:kTestAdUnitId withTestConfiguration:config];
    MPRewardedVideoReward * reward = [MPRewardedVideo availableRewardsForAdUnitID:kTestAdUnitId][0];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:kTestAdUnitId fromViewController:[UIViewController new] withReward:reward customData:customData];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(s2sUrl);

    NSString * uriEncodedCustomData = @"%7B%20%22key%22%3A%20%22some%20value%20with%20spaces%22%20%7D";
    NSString * expectedQueryParam = [NSString stringWithFormat:@"rcd=%@", uriEncodedCustomData];
    XCTAssert([s2sUrl.absoluteString containsString:expectedQueryParam]);
}

- (void)testCustomDataLocalReward {
    // Generate a custom data string that is well under 8196 characters
    NSString * customData = [@"" stringByPaddingToLength:512 withString:@"test" startingAtIndex:0];

    // Setup rewarded ad configuration
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameHeaderKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountHeaderKey: @"3",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
    };

    // Configure delegate handler to listen for the reward event.
    __block MPRewardedVideoReward * rewardForUser = nil;
    delegateHandler.shouldRewardUser = ^(MPRewardedVideoReward * reward) {
        rewardForUser = reward;
        [expectation fulfill];
    };

    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:kTestAdUnitId withTestConfiguration:config];
    MPRewardedVideoReward * reward = [MPRewardedVideo availableRewardsForAdUnitID:kTestAdUnitId][0];

    MPRewardedVideoAdManager * manager = [MPRewardedVideo adManagerForAdUnitId:kTestAdUnitId];
    MPRewardedVideoAdapter * adapter = manager.adapter;

    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:kTestAdUnitId fromViewController:[UIViewController new] withReward:reward customData:customData];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNil(s2sUrl);
    XCTAssertNotNil(adapter);
    XCTAssertNil(adapter.urlEncodedCustomData);
}

- (void)testNetworkIdentifierInRewardCallback {
    // Setup rewarded ad configuration
    NSDictionary * headers = @{ kCustomEventClassNameHeaderKey: @"MPMockChartboostRewardedVideoCustomEvent",
                                kRewardedVideoCurrencyNameHeaderKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountHeaderKey: @"3",
                                kRewardedVideoCompletionUrlHeaderKey: @"https://test.com?verifier=123",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
        [expectation fulfill];
    };

    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:kTestAdUnitId withTestConfiguration:config];
    MPRewardedVideoReward * reward = [MPRewardedVideo availableRewardsForAdUnitID:kTestAdUnitId][0];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:kTestAdUnitId fromViewController:[UIViewController new] withReward:reward customData:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(s2sUrl);
    XCTAssert([s2sUrl.absoluteString containsString:@"cec=MPMockChartboostRewardedVideoCustomEvent"]);
}

- (void)testMoPubNetworkIdentifierInRewardCallback {
    // Setup rewarded ad configuration
    NSDictionary * headers = @{ kAdTypeHeaderKey: @"rewarded_video",
                                kCustomEventClassNameHeaderKey: @"rewarded_video",
                                kRewardedVideoCurrencyNameHeaderKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountHeaderKey: @"3",
                                kRewardedVideoCompletionUrlHeaderKey: @"https://test.com?verifier=123",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];

    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate that listens for S2S connection event.
    __block NSURL * s2sUrl = nil;
    MPRewardedVideo.didSendServerToServerCallbackUrl = ^(NSURL * url) {
        s2sUrl = url;
        [expectation fulfill];
    };

    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:kTestAdUnitId withTestConfiguration:config];
    MPRewardedVideoReward * reward = [MPRewardedVideo availableRewardsForAdUnitID:kTestAdUnitId][0];
    [MPRewardedVideo presentRewardedVideoAdForAdUnitID:kTestAdUnitId fromViewController:[UIViewController new] withReward:reward customData:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(s2sUrl);
    XCTAssert([s2sUrl.absoluteString containsString:@"cec=MPMoPubRewardedVideoCustomEvent"]);
}

@end
