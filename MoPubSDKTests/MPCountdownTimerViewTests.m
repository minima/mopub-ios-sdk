//
//  MPCountdownTimerViewTests.m
//  MoPubSDK
//
//  Copyright © 2016 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPCountdownTimerView.h"

static const NSTimeInterval kTestTimeout   = 15; // seconds
static const NSTimeInterval kTimerDuration = 7; // seconds

@interface MPCountdownTimerViewTests : XCTestCase
@property (nonatomic, strong) MPCountdownTimerView * timerView;
@end

@implementation MPCountdownTimerViewTests

#pragma mark - Setup

- (void)setUp {
    [super setUp];
    self.timerView = [[MPCountdownTimerView alloc] initWithFrame:CGRectMake(0, 0, 40, 40) duration:kTimerDuration];
}

- (void)tearDown {
    self.timerView = nil;
    [super tearDown];
}

#pragma mark - Tests

// Tests that attempting to start an already running timer will do nothing.
- (void)testDoubleStart {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for timer completion block to fire."];

    __block BOOL completionFired = NO;
    [self.timerView startWithTimerCompletion:^(BOOL hasElapsed) {
        completionFired = YES;
        [expectation fulfill];
    }];

    [self.timerView startWithTimerCompletion:^(BOOL hasElapsed) {
        XCTFail(@"This timer completion block should never have been invoked.");
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssert(completionFired, @"Countdown timer completion block failed to fire.");
}

// Tests that the completion block for the timer executes after the timer has elapsed.
- (void)testElapses {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for timer completion block to fire."];

    __block BOOL completionFired = NO;
    [self.timerView startWithTimerCompletion:^(BOOL hasElapsed) {
        completionFired = YES;
        [expectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssert(completionFired, @"Countdown timer completion block failed to fire.");
}

// Tests initialization with an invalid duration.
- (void)testInvalidDuration {
    self.timerView = [[MPCountdownTimerView alloc] initWithFrame:CGRectMake(0, 0, 40, 40) duration:-1];

    XCTAssertNil(self.timerView);
}

// Tests pausing a stopped timer does nothing.
- (void)testNoOpPause {
    [self.timerView pause];

    XCTAssertFalse(self.timerView.isPaused);
}

// Tests resuming a stopped timer does nothing.
- (void)testNoOpResume {
    [self.timerView resume];

    XCTAssertFalse(self.timerView.isPaused);
    XCTAssertFalse(self.timerView.isActive);
}

// Tests stopping a stopped timer does nothing.
- (void)testNoOpStop {
    [self.timerView stopAndSignalCompletion:NO];

    XCTAssertFalse(self.timerView.isActive);
}

// Tests that the timer has successfully paused operation.
- (void)testPause {
    [self.timerView startWithTimerCompletion:nil];
    [self.timerView pause];

    XCTAssertTrue(self.timerView.isPaused);
}

// Tests that the timer has resumed operation.
- (void)testResume {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for timer completion block to fire."];

    __block BOOL completionFired = NO;
    [self.timerView startWithTimerCompletion:^(BOOL hasElapsed) {
        completionFired = YES;
        [expectation fulfill];
    }];

    // Pause the timer.
    [self.timerView pause];
    XCTAssertTrue(self.timerView.isPaused);

    // Resume the timer.
    [self.timerView resume];
    XCTAssertFalse(self.timerView.isPaused);

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssert(completionFired, @"Countdown timer completion block failed to fire.");
}

// Tests that the timer has stopped operation.
- (void)testStop {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for timer completion block to fire."];

    __block BOOL completionFired = NO;
    [self.timerView startWithTimerCompletion:^(BOOL hasElapsed) {
        completionFired = YES;
        [expectation fulfill];
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.timerView stopAndSignalCompletion:YES];
    });

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssert(completionFired, @"Countdown timer completion block failed to fire.");
    XCTAssertFalse(self.timerView.isActive);
}

// Tests that the timer has stopped operation without signaling the completion block.
- (void)testStopAndNoSignal {
    XCTestExpectation * expectation = [self expectationWithDescription:@"Wait for timer completion block to fire."];

    __block BOOL completionFired = NO;
    [self.timerView startWithTimerCompletion:^(BOOL hasElapsed) {
        completionFired = YES;
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.timerView stopAndSignalCompletion:NO];
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError * _Nullable error) {
        XCTAssertNil(error);
    }];

    XCTAssertFalse(completionFired, @"Countdown timer completion block should not have fired.");
    XCTAssertFalse(self.timerView.isActive);
}

@end
