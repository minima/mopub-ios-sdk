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
#import "MPError.h"

static NSTimeInterval const kTimeoutTime = 0.5;

@interface MPAdServerCommunicatorTests : XCTestCase

@property (nonatomic, strong) MPAdServerCommunicator *communicator;
@property (nonatomic, strong) MPAdserverCommunicatorDelegateHandler *communicatorDelegateHandler;

@end

@implementation MPAdServerCommunicatorTests

- (void)setUp {
    [super setUp];

    self.communicatorDelegateHandler = [[MPAdserverCommunicatorDelegateHandler alloc] init];
    self.communicator = [[MPAdServerCommunicator alloc] initWithDelegate:self.communicatorDelegateHandler];
    self.communicator.loading = YES;
}

- (void)tearDown {
    self.communicator = nil;
    self.communicatorDelegateHandler = nil;

    [super tearDown];
}

- (void)testMultipleAdResponses {
    // Set up response with three configurations
    NSDictionary *headers = @{@"X-Ad-Response-Type": @"multi"};
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

    // Check for three configurations
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData headers:headers];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 3);
    XCTAssertFalse(self.communicator.loading);
}

- (void)testOneAdResponseViaMultiHeader {
    // Set up response with one configurations
    NSDictionary *headers = @{@"X-Ad-Response-Type": @"multi"};
    NSDictionary *responseDataDict = @{
                                       @"ad-responses":
                                           @[
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

    // Check for one configuration
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData headers:headers];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 1);
    XCTAssertFalse(self.communicator.loading);
}

- (void)testOneAdResponseViaNormalHeadersAndBody {
    // Set up response the old way
    NSDictionary *headers = @{};
    NSData *responseData = [NSMutableData dataWithData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];

    // Check for one configuration
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for success delegate to be called"];
    __block NSArray<MPAdConfiguration *> *adConfigurations;
    self.communicatorDelegateHandler.communicatorDidReceiveAdConfigurations = ^(NSArray<MPAdConfiguration *> *configurations){
        adConfigurations = configurations;
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData headers:headers];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertNotNil(adConfigurations);
    XCTAssert(adConfigurations.count == 1);
    XCTAssertFalse(self.communicator.loading);
}

- (void)testJSONParseError {
    // Set up response with broken JSON
    NSDictionary *headers = @{@"X-Ad-Response-Type": @"multi"};
    NSString *brokenJsonStringData = @"{\"ad-responses\":{{\"headers\":{},\"adm\":\"\",\"body\":\"\"},{\"headers\":{},\"body\":\"\"},{\"headers\":{},\"adm\":\"\",\"body\":\"\"}]}";
    NSData *responseData = [NSMutableData dataWithData:[brokenJsonStringData dataUsingEncoding:NSUTF8StringEncoding]];

    // Check for error delegate
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for error delegate to be called"];
    self.communicatorDelegateHandler.communicatorDidFailWithError = ^(NSError *error){
        [expectation fulfill];
    };
    [self.communicator didFinishLoadingWithData:responseData headers:headers];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssertFalse(self.communicator.loading);
}

- (void)testNoAdResponsesError {
    // Set up response with no ad-responses entry
    NSDictionary *headers = @{@"X-Ad-Response-Type": @"multi"};
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
    [self.communicator didFinishLoadingWithData:responseData headers:headers];

    [self waitForExpectationsWithTimeout:kTimeoutTime handler:^(NSError *error){
        XCTAssertNil(error);
    }];

    XCTAssert(errorCode == MOPUBErrorUnableToParseJSONAdResponse);
    XCTAssertFalse(self.communicator.loading);
}

@end
