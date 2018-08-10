//
//  MPRewardedVideoRewardTests.m
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPRewardedVideoReward.h"

@interface MPRewardedVideoRewardTests : XCTestCase

@end

@implementation MPRewardedVideoRewardTests

- (void)testUnicodeRewards {
    MPRewardedVideoReward * reward = [[MPRewardedVideoReward alloc] initWithCurrencyType:@"🐱🌟" amount:@(100)];
    XCTAssertNotNil(reward);
}

@end
