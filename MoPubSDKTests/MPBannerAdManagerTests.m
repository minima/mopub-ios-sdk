//
//  MPBannerAdManagerTests.m
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPAdConfigurationFactory.h"
#import "MPBannerAdManager.h"
#import "MPBannerAdManager+Testing.h"
#import "MPBannerAdManagerDelegateHandler.h"
#import "MPMockAdServerCommunicator.h"

static const NSTimeInterval kDefaultTimeout = 10;

@interface MPBannerAdManagerTests : XCTestCase

@end

@implementation MPBannerAdManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Networking

- (void)testEmptyConfigurationArray {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for banner load"];

    MPBannerAdManagerDelegateHandler * handler = [MPBannerAdManagerDelegateHandler new];
    handler.didFailToLoadAd = ^{
        [expectation fulfill];
    };

    MPBannerAdManager * manager = [[MPBannerAdManager alloc] initWithDelegate:handler];
    [manager communicatorDidReceiveAdConfigurations:@[]];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];
}

- (void)testNilConfigurationArray {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for banner load"];

    MPBannerAdManagerDelegateHandler * handler = [MPBannerAdManagerDelegateHandler new];
    handler.didFailToLoadAd = ^{
        [expectation fulfill];
    };

    MPBannerAdManager * manager = [[MPBannerAdManager alloc] initWithDelegate:handler];
    [manager communicatorDidReceiveAdConfigurations:nil];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];
}

- (void)testMultipleResponsesFirstSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for banner load"];

    MPBannerAdManagerDelegateHandler * handler = [MPBannerAdManagerDelegateHandler new];
    handler.didLoadAd = ^{
        [expectation fulfill];
    };
    handler.didFailToLoadAd = ^{
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * bannerThatShouldLoad = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPMockBannerCustomEvent"];
    MPAdConfiguration * bannerLoadThatShouldNotLoad = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPMockBannerCustomEvent"];
    MPAdConfiguration * bannerLoadFail = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[bannerThatShouldLoad, bannerLoadThatShouldNotLoad, bannerLoadFail];

    MPBannerAdManager * manager = [[MPBannerAdManager alloc] initWithDelegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    manager.communicator = communicator;
    [manager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 1);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 1);
}

- (void)testMultipleResponsesMiddleSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for banner load"];

    MPBannerAdManagerDelegateHandler * handler = [MPBannerAdManagerDelegateHandler new];
    handler.didLoadAd = ^{
        [expectation fulfill];
    };
    handler.didFailToLoadAd = ^{
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * bannerThatShouldLoad = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPMockBannerCustomEvent"];
    MPAdConfiguration * bannerLoadThatShouldNotLoad = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPMockBannerCustomEvent"];
    MPAdConfiguration * bannerLoadFail = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[bannerLoadFail, bannerThatShouldLoad, bannerLoadThatShouldNotLoad];

    MPBannerAdManager * manager = [[MPBannerAdManager alloc] initWithDelegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    manager.communicator = communicator;
    [manager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 2);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 2);
}

- (void)testMultipleResponsesLastSuccess {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for banner load"];

    MPBannerAdManagerDelegateHandler * handler = [MPBannerAdManagerDelegateHandler new];
    handler.didLoadAd = ^{
        [expectation fulfill];
    };
    handler.didFailToLoadAd = ^{
        XCTFail(@"Encountered an unexpected load failure");
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * bannerThatShouldLoad = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"MPMockBannerCustomEvent"];
    MPAdConfiguration * bannerLoadFail1 = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    MPAdConfiguration * bannerLoadFail2 = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[bannerLoadFail1, bannerLoadFail2, bannerThatShouldLoad];

    MPBannerAdManager * manager = [[MPBannerAdManager alloc] initWithDelegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    manager.communicator = communicator;
    [manager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 3);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 3);
}

- (void)testMultipleResponsesFailOverToNextPage {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for banner load"];

    MPBannerAdManagerDelegateHandler * handler = [MPBannerAdManagerDelegateHandler new];
    handler.didFailToLoadAd = ^{
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * bannerLoadFail1 = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    MPAdConfiguration * bannerLoadFail2 = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[bannerLoadFail1, bannerLoadFail2];

    MPBannerAdManager * manager = [[MPBannerAdManager alloc] initWithDelegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    manager.communicator = communicator;
    [manager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
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
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for banner load"];

    MPBannerAdManagerDelegateHandler * handler = [MPBannerAdManagerDelegateHandler new];
    handler.didFailToLoadAd = ^{
        [expectation fulfill];
    };

    // Generate the ad configurations
    MPAdConfiguration * bannerLoadFail1 = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    MPAdConfiguration * bannerLoadFail2 = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"i_should_not_exist"];
    NSArray * configurations = @[bannerLoadFail1, bannerLoadFail2];

    MPBannerAdManager * manager = [[MPBannerAdManager alloc] initWithDelegate:handler];
    MPMockAdServerCommunicator * communicator = [[MPMockAdServerCommunicator alloc] initWithDelegate:manager];
    communicator.mockConfigurationsResponse = @[[MPAdConfigurationFactory clearResponse]];

    manager.communicator = communicator;
    [manager communicatorDidReceiveAdConfigurations:configurations];

    [self waitForExpectationsWithTimeout:kDefaultTimeout handler:^(NSError * _Nullable error) {
        if (error != nil) {
            XCTFail(@"Timed out");
        }
    }];

    // 2 failed attempts from first page
    XCTAssertTrue(communicator.numberOfBeforeLoadEventsFired == 2);
    XCTAssertTrue(communicator.numberOfAfterLoadEventsFired == 2);
    XCTAssert([communicator.lastUrlLoaded.absoluteString isEqualToString:@"http://ads.mopub.com/m/failURL"]);
}


@end
