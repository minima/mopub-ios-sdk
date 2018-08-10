//
//  MPAdServerCommunicatorTests.m
//  MoPubSDKTests
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPAdServerCommunicator.h"
#import "MPAdserverCommunicatorDelegateHandler.h"
#import "MPAdServerCommunicator+Testing.h"
#import "MPAdServerKeys.h"
#import "MPConsentManager+Testing.h"
#import "MPError.h"

static NSTimeInterval const kTimeoutTime = 0.5;

// Constants are from `MPAdServerCommunicator.m`
static NSString * const kAdResponsesKey = @"ad-responses";
static NSString * const kAdResonsesMetadataKey = @"metadata";
static NSString * const kAdResonsesContentKey = @"content";

@interface MPAdServerCommunicatorTests : XCTestCase

@property (nonatomic, strong) MPAdServerCommunicator *communicator;
@property (nonatomic, strong) MPAdserverCommunicatorDelegateHandler *communicatorDelegateHandler;

@end

@implementation MPAdServerCommunicatorTests

- (void)setUp {
    [super setUp];

    [[MPConsentManager sharedManager] setUpConsentManagerForTesting];

    self.communicatorDelegateHandler = [[MPAdserverCommunicatorDelegateHandler alloc] init];
    self.communicator = [[MPAdServerCommunicator alloc] initWithDelegate:self.communicatorDelegateHandler];
    self.communicator.loading = YES;
}

- (void)tearDown {
    self.communicator = nil;
    self.communicatorDelegateHandler = nil;

    [super tearDown];
}

#pragma mark - Multiple Responses

- (void)testMultipleAdResponses {
    // The response data is a JSON payload conforming to the structure:
    // {
    //     "ad-responses": [
    //                      {
    //                          "metadata": {
    //                              "adm": "some advanced bidding payload",
    //                              "x-ad-timeout-ms": 5000,
    //                              "x-adtype": "rewarded_video",
    //                          },
    //                          "content": "Ad markup goes here"
    //                      }
    //                      ],
    //     "x-next-url": "https:// ..."
    // }

    // Set up a valid response with three configurations
    NSDictionary *responseDataDict = @{
                                       kAdResponsesKey: @[
                                               @{ kAdResonsesMetadataKey: @{ @"adm": @"advanced bidding markup" }, kAdResonsesContentKey: @"mopub ad content" },
                                               @{ kAdResonsesMetadataKey: @{ @"x-adtype": @"banner" }, kAdResonsesContentKey: @"mopub ad content" },
                                               @{ kAdResonsesMetadataKey: @{ @"x-adtype": @"banner" }, kAdResonsesContentKey: @"mopub ad content" },
                                               ],
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 3 configurations
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 3);
    XCTAssertFalse(self.communicator.loading);
}

- (void)testZeroAdResponses {
    // Set up a valid response with three configurations
    NSDictionary *responseDataDict = @{ kAdResponsesKey: @[] };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 0 configurations
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 0);
    XCTAssertFalse(self.communicator.loading);
}

- (void)testMultipleAdResponsesWithNoMetadataField {
    // Set up an incorrect response with three configurations
    NSDictionary *responseDataDict = @{
                                       @"ad-responses":
                                           @[
                                               @{
                                                   @"headers": @{},
                                                   @"body": @"",
                                                   @"adm": @"",
                                               },
                                               @{
                                                   @"headers": @{},
                                                   @"body": @"",
                                               },
                                               @{
                                                   @"headers": @{},
                                                   @"body": @"",
                                                   @"adm": @"",
                                               },
                                           ],
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 0 configurations
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 0);
    XCTAssertFalse(self.communicator.loading);
}

- (void)testMergingMetaData {
    // The response data is a JSON payload conforming to the structure:
    // {
    //     "ad-responses": [
    //                      {
    //                          "metadata": {
    //                              "adm": "some advanced bidding payload",
    //                              "x-ad-timeout-ms": 5000,
    //                              "x-adtype": "rewarded_video",
    //                          },
    //                          "content": "Ad markup goes here"
    //                      }
    //                      ],
    //     "x-next-url": "https:// ..."
    // }

    // Set up a valid response
    NSDictionary *responseDataDict = @{
                                       kAdResponsesKey: @[
                                               @{ kAdResonsesMetadataKey: @{ @"adm": @"advanced bidding markup" }, kAdResonsesContentKey: @"mopub ad content" }
                                               ],
                                       @"x-next-url": @"https://www.mopub.com/unittest"
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 1 configuration
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 1);
    XCTAssertFalse(self.communicator.loading);

    MPAdConfiguration * config = adConfigurations.firstObject;
    XCTAssertNotNil(config);
    XCTAssert([config.nextURL.absoluteString isEqualToString:@"https://www.mopub.com/unittest"]);
}

- (void)testJSONParseError {
    // Set up response with broken JSON
    NSString *brokenJsonStringData = @"{\"ad-responses\":{{\"headers\":{},\"adm\":\"\",\"body\":\"\"},{\"headers\":{},\"body\":\"\"},{\"headers\":{},\"adm\":\"\",\"body\":\"\"}]}";
    NSData *responseData = [NSMutableData dataWithData:[brokenJsonStringData dataUsingEncoding:NSUTF8StringEncoding]];

    // Check for error delegate
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for error delegate to be called"];
    self.communicatorDelegateHandler.communicatorDidFailWithError = ^(NSError *error){
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertFalse(self.communicator.loading);
}

- (void)testNoDataResponsesError {
    // Set up response the old way
    NSData *responseData = [NSMutableData dataWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];

    // Check for one configuration
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for error delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    self.communicatorDelegateHandler.communicatorDidFailWithError = ^(NSError *error) {
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNil(adConfigurations);
    XCTAssert(adConfigurations.count == 0);
    XCTAssertFalse(self.communicator.loading);
}

- (void)testEmptyDataResponsesError {
    // Set up response with no ad-responses entry
    NSDictionary *responseDataDict = @{};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for error delegate
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for error delegate to be called"];
    __block NSInteger errorCode = -1;
    self.communicatorDelegateHandler.communicatorDidFailWithError = ^(NSError *error){
        errorCode = error.code;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssert(errorCode == MOPUBErrorUnableToParseJSONAdResponse);
    XCTAssertFalse(self.communicator.loading);
}

#pragma mark - Consent

- (void)testParseInvalidateConsent {
    // Initially set consent state to consented
    [MPConsentManager.sharedManager grantConsent];
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusConsented);

    // Set up a valid response with one configuration
    NSDictionary *responseDataDict = @{
                                       kInvalidateConsentKey: @"1",
                                       kAdResponsesKey: @[
                                               @{ kAdResonsesMetadataKey: @{ @"adm": @"advanced bidding markup" }, kAdResonsesContentKey: @"mopub ad content" },                                           ]
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 1 configuration
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 1);
    XCTAssertFalse(self.communicator.loading);

    // Verify that consent has been invalidated back to unknown.
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusUnknown);
}

- (void)testParseReacquireConsent {
    // Initially set consent state to consented
    [MPConsentManager.sharedManager grantConsent];
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusConsented);
    XCTAssertFalse(MPConsentManager.sharedManager.isConsentNeeded);

    // Set up a valid response with one configuration
    NSDictionary *responseDataDict = @{
                                       kReacquireConsentKey: @"1",
                                       kAdResponsesKey: @[
                                               @{ kAdResonsesMetadataKey: @{ @"adm": @"advanced bidding markup" }, kAdResonsesContentKey: @"mopub ad content" },                                           ]
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 1 configuration
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 1);
    XCTAssertFalse(self.communicator.loading);

    // Verify that consent has not changed, but needs to be reacquired
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusConsented);
    XCTAssertTrue(MPConsentManager.sharedManager.isConsentNeeded);
}

- (void)testParseForceExplicitNoConsent {
    // Initially set consent state to consented
    [MPConsentManager.sharedManager grantConsent];
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusConsented);

    // Set up a valid response with one configuration
    NSDictionary *responseDataDict = @{
                                       kForceExplicitNoKey: @"1",
                                       kAdResponsesKey: @[
                                               @{ kAdResonsesMetadataKey: @{ @"adm": @"advanced bidding markup" }, kAdResonsesContentKey: @"mopub ad content" },                                           ]
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 1 configuration
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 1);
    XCTAssertFalse(self.communicator.loading);

    // Verify that consent has been forced to explicit no
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusDenied);
}

- (void)testParseForceGDPRApplies {
    // Initially set GDPR applicable state to not applicable
    [MPConsentManager.sharedManager setIsGDPRApplicable:MPBoolNo];
    XCTAssert(MPConsentManager.sharedManager.isGDPRApplicable == MPBoolNo);

    // Set up a valid response with one configuration
    NSDictionary *responseDataDict = @{
                                       kForceGDPRAppliesKey: @"1",
                                       kAdResponsesKey: @[
                                               @{ kAdResonsesMetadataKey: @{ @"adm": @"advanced bidding markup" }, kAdResonsesContentKey: @"mopub ad content" },                                           ]
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 1 configuration
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 1);
    XCTAssertFalse(self.communicator.loading);

    // Verify that GDPR applies
    XCTAssertTrue(MPConsentManager.sharedManager.isGDPRApplicable);
}

- (void)testConsentForceExplicitNoTakesPriorityOverInvalidateConsent {
    // Initially set consent state to consented
    [MPConsentManager.sharedManager grantConsent];
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusConsented);

    // Set up a valid response with one configuration
    NSDictionary *responseDataDict = @{
                                       kInvalidateConsentKey: @"1",
                                       kForceExplicitNoKey: @"1",
                                       kAdResponsesKey: @[
                                               @{ kAdResonsesMetadataKey: @{ @"adm": @"advanced bidding markup" }, kAdResonsesContentKey: @"mopub ad content" },                                           ]
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 1 configuration
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 1);
    XCTAssertFalse(self.communicator.loading);

    // Verify that consent has been forced to explicit no
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusDenied);
}

- (void)testConsentForceExplicitNoDoesNothingWhenMalformed {
    // Initially set consent state to consented
    [MPConsentManager.sharedManager grantConsent];
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusConsented);

    // Set up a valid response with one configuration
    NSDictionary *responseDataDict = @{
                                       kForceExplicitNoKey: @"kjshgkjsrhgkwerhgq",
                                       kAdResponsesKey: @[
                                               @{ kAdResonsesMetadataKey: @{ @"adm": @"advanced bidding markup" }, kAdResonsesContentKey: @"mopub ad content" },                                           ]
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 1 configuration
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 1);
    XCTAssertFalse(self.communicator.loading);

    // Verify that consent has not changed
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusConsented);
}

- (void)testConsentInvalidateConsentDoesNothingWhenMalformed {
    // Initially set consent state to consented
    [MPConsentManager.sharedManager grantConsent];
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusConsented);

    // Set up a valid response with one configuration
    NSDictionary *responseDataDict = @{
                                       kInvalidateConsentKey: @"kjshgkjsrhgkwerhgq",
                                       kAdResponsesKey: @[
                                               @{ kAdResonsesMetadataKey: @{ @"adm": @"advanced bidding markup" }, kAdResonsesContentKey: @"mopub ad content" },                                           ]
                                       };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseDataDict
                                                       options:0
                                                         error:nil];
    XCTAssertNotNil(jsonData);
    NSData *responseData = [NSMutableData dataWithData:jsonData];

    // Check for 1 configuration
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 1);
    XCTAssertFalse(self.communicator.loading);

    // Verify that consent has not changed
    XCTAssert(MPConsentManager.sharedManager.currentStatus == MPConsentStatusConsented);
}

@end
