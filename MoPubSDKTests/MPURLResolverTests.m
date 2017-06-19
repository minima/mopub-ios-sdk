//
//  MPURLResolverTests.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPURLResolver.h"
#import "MoPub.h"

static NSString * const kWebviewClickthroughURLBase = @"https://ads.mopub.com/m/aclk?appid=&cid=dfc18f7f101e40489e2a091c845a1cab&city=Burlingame&ckv=2&country_code=US&cppck=4C7BD&dev=x86_64&exclude_adgroups=0769f1d048214c4f9ff4c05d9871a95b&id=abc6bfe824634bc1b70dfc2cc78c6940&is_mraid=0&os=iOS&osv=10.3.0&req=083033d5e9b9412f9b37ae08468191c7&reqt=1495340380.0&rev=0&udid=ifa%3A237E6BB9-EF1B-4287-B21E-42A39A69D3BB&video_type=";

@interface MPURLResolver (Testing)

- (BOOL)shouldEnableClickthroughExperiment;

@end

@interface MPURLResolverTests : XCTestCase

@end

@implementation MPURLResolverTests

- (void)testResolverNonHttpNorHttps {
    NSURL *url = [NSURL URLWithString:@"mopubnativebrowser://navigate?url=https://twitter.com"];
    MPURLResolver *resolver = [MPURLResolver resolverWithURL:url completion:nil];
    [resolver start];


    XCTAssertFalse([resolver shouldEnableClickthroughExperiment]);
}

- (void)testHttpRedirectWithNativeSafari {
    [[MoPub sharedInstance] setClickthroughDisplayAgentType:MOPUBDisplayAgentTypeNativeSafari];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", kWebviewClickthroughURLBase, @"&r=https%3A%2F%2Fwww.mopub.com%2F"];
    NSURL *url = [NSURL URLWithString:urlStr];
    MPURLResolver *resolver = [MPURLResolver resolverWithURL:url completion:nil];
    [resolver start];

    XCTAssertTrue([resolver shouldEnableClickthroughExperiment]);
}

- (void)testHttpRedirectWithInAppBrowser {
    [[MoPub sharedInstance] setClickthroughDisplayAgentType:MOPUBDisplayAgentTypeInApp];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", kWebviewClickthroughURLBase, @"&r=https%3A%2F%2Fwww.mopub.com%2F"];
    NSURL *url = [NSURL URLWithString:urlStr];
    MPURLResolver *resolver = [MPURLResolver resolverWithURL:url completion:nil];
    [resolver start];

    XCTAssertFalse([resolver shouldEnableClickthroughExperiment]);
}

- (void)testMopubnativebrowserRedirectWithNativeSafari {
    [[MoPub sharedInstance] setClickthroughDisplayAgentType:MOPUBDisplayAgentTypeNativeSafari];

    NSString *urlStr = [NSString stringWithFormat:@"%@%@", kWebviewClickthroughURLBase, @"&r=mopubnativebrowser://navigate?url=https://twitter.com"];
    NSURL *url = [NSURL URLWithString:urlStr];
    MPURLResolver *resolver = [MPURLResolver resolverWithURL:url completion:nil];
    [resolver start];

    XCTAssertFalse([resolver shouldEnableClickthroughExperiment]);
}

- (void)testHttpNonRedirectWithNativeSafari {
    [[MoPub sharedInstance] setClickthroughDisplayAgentType:MOPUBDisplayAgentTypeNativeSafari];
    NSURL *url = [NSURL URLWithString:kWebviewClickthroughURLBase];
    MPURLResolver *resolver = [MPURLResolver resolverWithURL:url completion:nil];
    [resolver start];

    XCTAssertFalse([resolver shouldEnableClickthroughExperiment]);
}

- (void)testNonWebviewWithNativeSafari {
    [[MoPub sharedInstance] setClickthroughDisplayAgentType:MOPUBDisplayAgentTypeNativeSafari];

    NSURL *url = [NSURL URLWithString:@"https://ads.mopub.com"];
    MPURLResolver *resolver = [MPURLResolver resolverWithURL:url completion:nil];
    [resolver start];

    XCTAssertTrue([resolver shouldEnableClickthroughExperiment]);
}

- (void)testNonWebviewWithInappBrowser {
    [[MoPub sharedInstance] setClickthroughDisplayAgentType:MOPUBDisplayAgentTypeInApp];

    NSURL *url = [NSURL URLWithString:@"https://ads.mopub.com"];
    MPURLResolver *resolver = [MPURLResolver resolverWithURL:url completion:nil];
    [resolver start];

    XCTAssertFalse([resolver shouldEnableClickthroughExperiment]);
}

@end
