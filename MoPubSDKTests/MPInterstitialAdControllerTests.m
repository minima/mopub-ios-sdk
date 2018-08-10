//
//  MPInterstitialAdControllerTests.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPAdServerKeys.h"
#import "MPAPIEndpoints.h"
#import "MPInterstitialAdController.h"
#import "MPInterstitialAdController+Testing.h"
#import "MPInterstitialAdManager+Testing.h"
#import "MPMockAdServerCommunicator.h"
#import "NSURLComponents+Testing.h"
#import "MPURL.h"

@interface MPInterstitialAdControllerTests : XCTestCase
@property (nonatomic, strong) MPInterstitialAdController * interstitial;
@property (nonatomic, weak) MPMockAdServerCommunicator * mockAdServerCommunicator;
@end

@implementation MPInterstitialAdControllerTests

- (void)setUp {
    [super setUp];
    self.interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"FAKE_AD_UNIT_ID"];
    self.interstitial.manager.communicator = ({
        MPMockAdServerCommunicator * mock = [[MPMockAdServerCommunicator alloc] initWithDelegate:self.interstitial.manager];
        self.mockAdServerCommunicator = mock;
        mock;
    });
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Viewability

- (void)testViewabilityQueryParameter {
    // Interstitial ads should send a viewability query parameter.
    [self.interstitial loadAd];

    XCTAssertNotNil(self.mockAdServerCommunicator);
    XCTAssertNotNil(self.mockAdServerCommunicator.lastUrlLoaded);

    MPURL * url = [self.mockAdServerCommunicator.lastUrlLoaded isKindOfClass:[MPURL class]] ? (MPURL *)self.mockAdServerCommunicator.lastUrlLoaded : nil;
    XCTAssertNotNil(url);

    NSString * viewabilityValue = [url stringForPOSTDataKey:kViewabilityStatusKey];
    XCTAssertNotNil(viewabilityValue);
    XCTAssertTrue([viewabilityValue isEqualToString:@"1"]);
}

@end
