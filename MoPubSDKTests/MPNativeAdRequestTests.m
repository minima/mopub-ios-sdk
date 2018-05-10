//
//  MPNativeAdRequestTests.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPAPIEndpoints.h"
#import "MPNativeAdRequest.h"
#import "MPNativeAdRequest+Testing.h"
#import "MPMockAdServerCommunicator.h"
#import "NSURLComponents+Testing.h"

@interface MPNativeAdRequestTests : XCTestCase

@end

@implementation MPNativeAdRequestTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Viewability

- (void)testViewabilityQueryParameterNotPresent {
    // Native ads should not send a viewability query parameter.
    MPMockAdServerCommunicator * mockAdServerCommunicator = nil;
    MPNativeAdRequest * nativeAdRequest = [MPNativeAdRequest requestWithAdUnitIdentifier:@"FAKE_AD_UNIT_ID" rendererConfigurations:nil];
    nativeAdRequest.communicator = ({
        MPMockAdServerCommunicator * mock = [[MPMockAdServerCommunicator alloc] initWithDelegate:nativeAdRequest];
        mockAdServerCommunicator = mock;
        mock;
    });
    [nativeAdRequest startWithCompletionHandler:^(MPNativeAdRequest *request, MPNativeAd *response, NSError *error) {
        // The handler response doesn't matter.
    }];

    XCTAssertNotNil(mockAdServerCommunicator);
    XCTAssertNotNil(mockAdServerCommunicator.lastUrlLoaded);

    NSURL * url = mockAdServerCommunicator.lastUrlLoaded;
    NSURLComponents * urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];

    NSString * viewabilityQueryParamValue = [urlComponents valueForQueryParameter:@"vv"];
    XCTAssertNil(viewabilityQueryParamValue);
}

@end
