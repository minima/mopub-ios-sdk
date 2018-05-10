//
//  MPAdViewTests.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPAdView.h"
#import "MPAdView+Testing.h"
#import "MPAPIEndpoints.h"
#import "MPBannerAdManager+Testing.h"
#import "MPMockAdServerCommunicator.h"
#import "NSURLComponents+Testing.h"

@interface MPAdViewTests : XCTestCase
@property (nonatomic, strong) MPAdView * adView;
@property (nonatomic, weak) MPMockAdServerCommunicator * mockAdServerCommunicator;
@end

@implementation MPAdViewTests

- (void)setUp {
    [super setUp];

    self.adView = [[MPAdView alloc] initWithAdUnitId:@"FAKE_AD_UNIT_ID" size:MOPUB_BANNER_SIZE];
    self.adView.adManager.communicator = ({
        MPMockAdServerCommunicator * mock = [[MPMockAdServerCommunicator alloc] initWithDelegate:self.adView.adManager];
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
    // Banner ads should send a viewability query parameter.
    [self.adView loadAd];

    XCTAssertNotNil(self.mockAdServerCommunicator);
    XCTAssertNotNil(self.mockAdServerCommunicator.lastUrlLoaded);

    NSURL * url = self.mockAdServerCommunicator.lastUrlLoaded;
    NSURLComponents * urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];

    NSString * viewabilityQueryParamValue = [urlComponents valueForQueryParameter:@"vv"];
    XCTAssertNotNil(viewabilityQueryParamValue);
    XCTAssertTrue([viewabilityQueryParamValue isEqualToString:@"1"]);
}


@end
