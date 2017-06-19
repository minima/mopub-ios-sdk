//
//  MOPUBExperimentProviderTests.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPAdConfiguration+Testing.h"
#import "MOPUBExperimentProvider.h"
#import "MoPub.h"
#import "MPAdConfiguration.h"
#import "MOPUBExperimentProvider+Testing.h"

@interface MOPUBExperimentProviderTests : XCTestCase

@end

@implementation MOPUBExperimentProviderTests

- (void)testClickthroughExperimentDefault {
    [MOPUBExperimentProvider setDisplayAgentOverriddenByClientFlag:NO];
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:nil data:nil];
    XCTAssertEqual(config.clickthroughExperimentBrowserAgent, MOPUBDisplayAgentTypeInApp);
    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeInApp);
}

- (void)testClickthroughExperimentInApp {
    [MOPUBExperimentProvider setDisplayAgentOverriddenByClientFlag:NO];
    NSDictionary * headers = @{ kClickthroughExperimentBrowserAgent: @"0"};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
    XCTAssertEqual(config.clickthroughExperimentBrowserAgent, MOPUBDisplayAgentTypeInApp);
    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeInApp);
}

- (void)testClickthroughExperimentNativeBrowser {
    [MOPUBExperimentProvider setDisplayAgentOverriddenByClientFlag:NO];
    NSDictionary * headers = @{ kClickthroughExperimentBrowserAgent: @"1"};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
    XCTAssertEqual(config.clickthroughExperimentBrowserAgent, MOPUBDisplayAgentTypeNativeSafari);
    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeNativeSafari);
}

- (void)testClickthroughExperimentSafariViewController {
    [MOPUBExperimentProvider setDisplayAgentOverriddenByClientFlag:NO];
    NSDictionary * headers = @{ kClickthroughExperimentBrowserAgent: @"2"};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
    XCTAssertEqual(config.clickthroughExperimentBrowserAgent, MOPUBDisplayAgentTypeSafariViewController);
    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeSafariViewController);
}

- (void)testClickthroughClientOverride {
    [[MoPub sharedInstance] setClickthroughDisplayAgentType:MOPUBDisplayAgentTypeInApp];

    NSDictionary * headers = @{ kClickthroughExperimentBrowserAgent: @"2"};
    MPAdConfiguration * config = [[MPAdConfiguration alloc] initWithHeaders:headers data:nil];
    XCTAssertEqual(config.clickthroughExperimentBrowserAgent, MOPUBDisplayAgentTypeSafariViewController);

    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeInApp);

    // Display agent type is overridden to MOPUBDisplayAgentTypeSafariViewController
    [[MoPub sharedInstance] setClickthroughDisplayAgentType:MOPUBDisplayAgentTypeSafariViewController];
    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeSafariViewController);

    // Display agent type is overridden to MOPUBDisplayAgentTypeNativeSafari
    [[MoPub sharedInstance] setClickthroughDisplayAgentType:MOPUBDisplayAgentTypeNativeSafari];
    XCTAssertEqual([MOPUBExperimentProvider displayAgentType], MOPUBDisplayAgentTypeNativeSafari);
}

@end
