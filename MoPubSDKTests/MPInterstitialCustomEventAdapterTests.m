//
//  MPInterstitialCustomEventAdapterTests.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPInterstitialCustomEventAdapter.h"
#import "MPInterstitialAdapterDelegateHandler.h"
#import "MPInterstitialCustomEventAdapter+Testing.h"
#import "MPInterstitialCustomEvent.h"
#import "MPHTMLInterstitialCustomEvent.h"
#import "MPMRAIDInterstitialCustomEvent.h"
#import "MPConstants+Testing.h"

static NSTimeInterval const kTestTimeout = 2;

@interface MPInterstitialCustomEventAdapterTests : XCTestCase

@property (nonatomic, strong) MPInterstitialCustomEventAdapter *adapter;
@property (nonatomic, strong) MPInterstitialAdapterDelegateHandler *delegateHandler;

@end

@implementation MPInterstitialCustomEventAdapterTests

- (void)setUp {
    [super setUp];

    self.delegateHandler = [[MPInterstitialAdapterDelegateHandler alloc] init];
    self.adapter = [[MPInterstitialCustomEventAdapter alloc] initWithDelegate:self.delegateHandler];
}

// be sure `trackImpression` marks `hasTrackedImpression` as `YES`
- (void)testTrackImpressionSetsHasTrackedImpressionCorrectly {
    XCTAssertFalse(self.adapter.hasTrackedImpression);
    [self.adapter trackImpression];
    XCTAssertTrue(self.adapter.hasTrackedImpression);
}

// test that ad expires if no impression is tracked within the given limit, and be sure the callback is called
- (void)testAdWillExpireWithNoImpressionHTML {
    MPHTMLInterstitialCustomEvent *customEvent = [[MPHTMLInterstitialCustomEvent alloc] init];

    [self adWillExpireWithNoImpression:customEvent];
}

- (void)testAdWillExpireWithNoImpressionMRAID {
    MPMRAIDInterstitialCustomEvent *customEvent = [[MPMRAIDInterstitialCustomEvent alloc] init];

    [self adWillExpireWithNoImpression:customEvent];
}

- (void)adWillExpireWithNoImpression:(MPInterstitialCustomEvent *)customEvent {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for expiration delegate method to be triggered"];

    __block BOOL didExpire = NO;
    self.delegateHandler.didExpire = ^(MPBaseInterstitialAdapter *adapter) {
        didExpire = YES;
        [expectation fulfill];
    };

    [self.adapter interstitialCustomEvent:customEvent didLoadAd:nil];

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(didExpire);
    XCTAssertFalse(self.adapter.hasTrackedImpression);
}

// test ad does not expire if impression is tracked
- (void)testAdWillNotExpireIfImpressionIsTrackedHTML {
    MPHTMLInterstitialCustomEvent *customEvent = [[MPHTMLInterstitialCustomEvent alloc] init];

    [self adWillNotExpireIfImpressionIsTracked:customEvent];
}

- (void)testAdWillNotExpireIfImpressionIsTrackedMRAID {
    MPMRAIDInterstitialCustomEvent *customEvent = [[MPMRAIDInterstitialCustomEvent alloc] init];

    [self adWillNotExpireIfImpressionIsTracked:customEvent];
}

- (void)adWillNotExpireIfImpressionIsTracked:(MPInterstitialCustomEvent *)customEvent {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for expiration interval to elapse"];

    __block BOOL didExpire = NO;
    self.delegateHandler.didExpire = ^(MPBaseInterstitialAdapter *adapter) {
        didExpire = YES;
    };

    [self.adapter interstitialCustomEvent:customEvent didLoadAd:nil];
    [self.adapter trackImpression];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(([MPConstants adsExpirationInterval] + 0.5) * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       [expectation fulfill];
                   });

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertTrue(self.adapter.hasTrackedImpression);
    XCTAssertFalse(didExpire);
}

// test ad never expires if not mopub-specific custom event
- (void)testAdNeverExpiresIfNotMoPubCustomEvent {
    MPInterstitialCustomEvent *customEvent = [[MPInterstitialCustomEvent alloc] init];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Wait for expiration interval to elapse"];

    __block BOOL didExpire = NO;
    self.delegateHandler.didExpire = ^(MPBaseInterstitialAdapter *adapter) {
        didExpire = YES;
    };

    [self.adapter interstitialCustomEvent:customEvent didLoadAd:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(([MPConstants adsExpirationInterval] + 0.5) * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       [expectation fulfill];
                   });

    [self waitForExpectationsWithTimeout:kTestTimeout handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

    XCTAssertFalse(self.adapter.hasTrackedImpression);
    XCTAssertFalse(didExpire);
}

@end
