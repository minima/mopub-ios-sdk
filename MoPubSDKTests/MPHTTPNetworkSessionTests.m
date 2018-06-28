//
//  MPHTTPNetworkSessionTests.m
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPHTTPNetworkSession.h"
#import "MPHTTPNetworkSession+Testing.h"

@interface MPHTTPNetworkSessionTests : XCTestCase

@end

@implementation MPHTTPNetworkSessionTests

- (void)testThreadSafeSessionAccess {
    MPHTTPNetworkSession * session = MPHTTPNetworkSession.sharedInstance;
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://www.mopub.com"]];
    NSURLSessionDataTask * task = [session.sharedSession dataTaskWithRequest:request];
    MPHTTPNetworkTaskData * taskData = [[MPHTTPNetworkTaskData alloc] initWithResponseHandler:nil errorHandler:nil shouldRedirectWithNewRequest:nil];

    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for concurrency test to finish"];
    dispatch_group_t testsGroup = dispatch_group_create();
    dispatch_group_async(testsGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [session setSessionData:taskData forTask:task];
    });

    dispatch_group_async(testsGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        MPHTTPNetworkTaskData * data = [session sessionDataForTask:task];
        data.responseData = [NSMutableData new];
    });

    dispatch_group_async(testsGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        for (int i = 0 ; i < 1000; i++) {
            NSString * testString = @"i'm a test";
            NSData * newData = [testString dataUsingEncoding:NSUTF8StringEncoding];

            [session appendData:newData toSessionDataForTask:task];
        }
    });

    dispatch_group_async(testsGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        for (int i = 0 ; i < 1000; i++) {
            NSString * testString = @"poop";
            NSData * newData = [testString dataUsingEncoding:NSUTF8StringEncoding];

            [session appendData:newData toSessionDataForTask:task];
        }
    });

    dispatch_group_async(testsGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        MPHTTPNetworkTaskData * data2 = [session sessionDataForTask:task];
        data2.responseData = [NSMutableData new];
    });

    dispatch_group_notify(testsGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:30 handler:nil];
}

@end
