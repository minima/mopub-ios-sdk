//
//  MPRewardedVideoAdManagerTests.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPAdConfiguration.h"
#import "MPAdConfigurationFactory.h"
#import "MPAdServerKeys.h"
#import "MPAPIEndpoints.h"
#import "MPRewardedVideoAdManager.h"
#import "MPRewardedVideoAdManager+Testing.h"
#import "MPRewardedVideoDelegateHandler.h"
#import "MPRewardedVideoReward.h"
#import "MPMockAdServerCommunicator.h"
#import "MPMockRewardedVideoCustomEvent.h"
#import "MPURL.h"
#import "NSURLComponents+Testing.h"

static NSString * const kTestAdUnitId = @"967f82c7-c059-4ae8-8cb6-41c34265b1ef";
static const NSTimeInterval kTestTimeout   = 2; // seconds

@interface MPRewardedVideoAdManagerTests : XCTestCase

@end

@implementation MPRewardedVideoAdManagerTests

#pragma mark - Currency

- (void)testRewardedSingleCurrencyPresentationSuccess {
    // Setup rewarded ad configuration
    NSDictionary * headers = @{ kRewardedVideoCurrencyNameMetadataKey: @"Diamonds",
                                kRewardedVideoCurrencyAmountMetadataKey: @"3",
                                };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil];

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
    [rewardedAd presentRewardedVideoAdFromViewController:nil withReward:nil customData:nil];

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
    NSDictionary * headers = @{ kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"name": @"Coins", @"amount": @(8) } ] } };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil];

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
    [rewardedAd presentRewardedVideoAdFromViewController:nil withReward:nil customData:nil];

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
    NSDictionary * headers = @{ kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"name": @"Coins", @"amount": @(8) }, @{ @"name": @"Diamonds", @"amount": @(1) }, @{ @"name": @"Energy", @"amount": @(20) } ] } };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil];

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
    [rewardedAd presentRewardedVideoAdFromViewController:nil withReward:rewardedAd.availableRewards[1] customData:nil];

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
    NSDictionary * headers = @{ kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"name": @"Coins", @"amount": @(8) }, @{ @"name": @"Diamonds", @"amount": @(1) }, @{ @"name": @"Energy", @"amount": @(20) } ] } };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil];

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
    [rewardedAd presentRewardedVideoAdFromViewController:nil withReward:nil customData:nil];

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
    NSDictionary * headers = @{ kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"name": @"Coins", @"amount": @(8) }, @{ @"name": @"Diamonds", @"amount": @(1) }, @{ @"name": @"Energy", @"amount": @(20) } ] } };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil];

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
    [rewardedAd presentRewardedVideoAdFromViewController:nil withReward:nil customData:nil];

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
    NSDictionary * headers = @{ kRewardedCurrenciesMetadataKey: @{ @"rewards": @[ @{ @"name": @"Coins", @"amount": @(8) }, @{ @"name": @"Diamonds", @"amount": @(1) }, @{ @"name": @"Energy", @"amount": @(20) } ] } };
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithMetadata:headers data:nil];

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
    [rewardedAd presentRewardedVideoAdFromViewController:nil withReward:badReward customData:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertNil(rewardForUser);
    XCTAssertTrue(didFail);
}

- (void)testPresentationFailure {
    // Semaphore to wait for asynchronous method to finish before continuing the test.
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for reward completion block to fire."];

    // Configure delegate handler to listen for the error event.
    __block BOOL didFail = NO;
    MPRewardedVideoDelegateHandler * delegateHandler = [MPRewardedVideoDelegateHandler new];
    delegateHandler.didFailToPlayAd = ^() {
        didFail = YES;
        [expectation fulfill];
    };

    MPRewardedVideoAdManager * rewardedAd = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:kTestAdUnitId delegate:delegateHandler];
    [rewardedAd presentRewardedVideoAdFromViewController:nil withReward:nil customData:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(didFail);
}

#pragma mark - Network

- (void)testEmptyConfigurationArray {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rewardedVideo load"];

    MPRewardedVideoDelegateHandler * handler = [MPRewardedVideoDelegateHandler new];
    handler.didFailToLoadAd = ^{
        [expectation fulfill];
    };

    MPRewardedVideoAdManager * manager = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:kTestAdUnitId delegate:handler];
    [manager communicatorDidReceiveAdConfigurations:@[]];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];
}

- (void)testNilConfigurationArray {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rewardedVideo load"];

    MPRewardedVideoDelegateHandler * handler = [MPRewardedVideoDelegateHandler new];
    handler.didFailToLoadAd = ^{
        [expectation fulfill];
    };

    MPRewardedVideoAdManager * manager = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:kTestAdUnitId delegate:handler];
    [manager communicatorDidReceiveAdConfigurations:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];
}

- (void)testMultipleResponsesFirstSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rewardedVideo load"];

    MPRewardedVideoDelegateHandler * handler = [MPRewardedVideoDelegateHandler new];
    handler.didLoadAd = ^{
        [expectation fulfill];
    };
    handler.didFailToLoadAd = ^{
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * rewardedVideoThatShouldLoad = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithCustomEventClassName:@"MPMockRewardedVideoCustomEvent"];
    MPAdConfiguration * rewardedVideoLoadThatShouldNotLoad = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithCustomEventClassName:@"MPMockRewardedVideoCustomEvent"];
    MPAdConfiguration * rewardedVideoLoadFail = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[rewardedVideoThatShouldLoad, rewardedVideoLoadThatShouldNotLoad, rewardedVideoLoadFail];

    MPRewardedVideoAdManager * manager = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:kTestAdUnitId delegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    manager.communicator = communicator;
    [manager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 1);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 1);
}

- (void)testMultipleResponsesMiddleSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rewardedVideo load"];

    MPRewardedVideoDelegateHandler * handler = [MPRewardedVideoDelegateHandler new];
    handler.didLoadAd = ^{
        [expectation fulfill];
    };
    handler.didFailToLoadAd = ^{
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * rewardedVideoThatShouldLoad = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithCustomEventClassName:@"MPMockRewardedVideoCustomEvent"];
    MPAdConfiguration * rewardedVideoLoadThatShouldNotLoad = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithCustomEventClassName:@"MPMockRewardedVideoCustomEvent"];
    MPAdConfiguration * rewardedVideoLoadFail = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[rewardedVideoLoadFail, rewardedVideoThatShouldLoad, rewardedVideoLoadThatShouldNotLoad];

    MPRewardedVideoAdManager * manager = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:kTestAdUnitId delegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    manager.communicator = communicator;
    [manager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 2);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 2);
}

- (void)testMultipleResponsesLastSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rewardedVideo load"];

    MPRewardedVideoDelegateHandler * handler = [MPRewardedVideoDelegateHandler new];
    handler.didLoadAd = ^{
        [expectation fulfill];
    };
    handler.didFailToLoadAd = ^{
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * rewardedVideoThatShouldLoad = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithCustomEventClassName:@"MPMockRewardedVideoCustomEvent"];
    MPAdConfiguration * rewardedVideoLoadFail1 = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    MPAdConfiguration * rewardedVideoLoadFail2 = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[rewardedVideoLoadFail1, rewardedVideoLoadFail2, rewardedVideoThatShouldLoad];

    MPRewardedVideoAdManager * manager = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:kTestAdUnitId delegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    manager.communicator = communicator;
    [manager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 3);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 3);
}

- (void)testMultipleResponsesFailOverToNextPage {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rewardedVideo load"];

    MPRewardedVideoDelegateHandler * handler = [MPRewardedVideoDelegateHandler new];
    handler.didFailToLoadAd = ^{
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * rewardedVideoLoadFail1 = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    MPAdConfiguration * rewardedVideoLoadFail2 = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[rewardedVideoLoadFail1, rewardedVideoLoadFail2];

    MPRewardedVideoAdManager * manager = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:kTestAdUnitId delegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    manager.communicator = communicator;
    [manager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // 2 failed attempts from first page
    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 2);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 2);
    XCTAssert([communicator.lastUrlLoaded.absoluteString isEqualToString:@"http://ads.mopub.com/m/failURL"]);
}

- (void)testMultipleResponsesFailOverToNextPageClear {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for rewardedVideo load"];

    MPRewardedVideoDelegateHandler * handler = [MPRewardedVideoDelegateHandler new];
    handler.didFailToLoadAd = ^{
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * rewardedVideoLoadFail1 = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    MPAdConfiguration * rewardedVideoLoadFail2 = [MPAdConfigurationFactory defaultRewardedVideoConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[rewardedVideoLoadFail1, rewardedVideoLoadFail2];

    MPRewardedVideoAdManager * manager = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:kTestAdUnitId delegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    communicator.mockConfigurationsResponse = @[[MPAdConfigurationFactory clearResponse]];

    manager.communicator = communicator;
    [manager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // 2 failed attempts from first page
    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 2);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 2);
    XCTAssert([communicator.lastUrlLoaded.absoluteString isEqualToString:@"http://ads.mopub.com/m/failURL"]);
}

#pragma mark - Viewability

- (void)testViewabilityPOSTParameter {
    // Rewarded video ads should send a viewability query parameter.
    MPMockAdServerCommunicator * mockAdServerCommunicator = nil;
    MPRewardedVideoAdManager * rewardedAd = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:kTestAdUnitId delegate:nil];
    rewardedAd.communicator = ({
        MPMockAdServerCommunicator * mock = [[MPMockAdServerCommunicator alloc] initWithDelegate:rewardedAd];
        mockAdServerCommunicator = mock;
        mock;
    });
    [rewardedAd loadRewardedVideoAdWithKeywords:nil userDataKeywords:nil location:nil customerId:nil];

    XCTAssertNotNil(mockAdServerCommunicator);
    XCTAssertNotNil(mockAdServerCommunicator.lastUrlLoaded);

    MPURL * url = [mockAdServerCommunicator.lastUrlLoaded isKindOfClass:[MPURL class]] ? (MPURL *)mockAdServerCommunicator.lastUrlLoaded : nil;
    XCTAssertNotNil(url);

    NSString * viewabilityValue = [url stringForPOSTDataKey:kViewabilityStatusKey];
    XCTAssertNotNil(viewabilityValue);
    XCTAssertTrue([viewabilityValue isEqualToString:@"1"]);
}

@end
