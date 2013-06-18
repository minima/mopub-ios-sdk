//
//  FakeMPInstanceProvider.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPInstanceProvider.h"
#import "FakeMPAdServerCommunicator.h"
#import "FakeInterstitialAdapter.h"
#import "FakeMPAnalyticsTracker.h"
#import <iAd/iAd.h>
#import "GADInterstitial.h"
#import "GADBannerView.h"
#import "FakeMMInterstitial.h"
#import "FakeInterstitialCustomEvent.h"
#import "Chartboost.h"
#import "FakeGSFullscreenAd.h"
#import "IMAdInterstitial.h"
#import "IMAdView.h"
#import "MPInterstitialAdManager.h"
#import "GADRequest.h"
#import "FakeMMAdView.h"
#import "FakeMPReachability.h"
#import "FakeGSBannerAdView.h"
#import "MPBaseBannerAdapter.h"
#import "FakeBannerCustomEvent.h"
#import "FakeMPTimer.h"
#import "FakeCTCarrier.h"

@interface FakeMPInstanceProvider : MPInstanceProvider

#pragma mark - Fetching Ads
@property (nonatomic, assign) FakeMPAdServerCommunicator *lastFakeMPAdServerCommunicator;

#pragma mark - Banners
@property (nonatomic, assign) MPBaseBannerAdapter *fakeBannerAdapter;
@property (nonatomic, assign) FakeBannerCustomEvent *fakeBannerCustomEvent;

#pragma mark - Interstitials
@property (nonatomic, assign) MPInterstitialAdManager *fakeMPInterstitialAdManager;
@property (nonatomic, assign) MPBaseInterstitialAdapter *fakeInterstitialAdapter;
@property (nonatomic, assign) FakeInterstitialCustomEvent *fakeInterstitialCustomEvent;
@property (nonatomic, assign) MPHTMLInterstitialViewController *fakeMPHTMLInterstitialViewController;
@property (nonatomic, assign) MPMRAIDInterstitialViewController *fakeMPMRAIDInterstitialViewController;

#pragma mark - HTML Ads
@property (nonatomic, assign) MPAdWebView *fakeMPAdWebView;
@property (nonatomic, assign) MPAdWebViewAgent *fakeMPAdWebViewAgent;

#pragma mark - URL Handling
@property (nonatomic, assign) MPURLResolver *fakeMPURLResolver;
@property (nonatomic, assign) MPAdDestinationDisplayAgent *fakeMPAdDestinationDisplayAgent;

#pragma mark - Utilities
@property (nonatomic, assign) FakeMPReachability *fakeMPReachability;
@property (nonatomic, assign) FakeCTCarrier *fakeCTCarrier;

- (NSString *)userAgent;
- (FakeMPAnalyticsTracker *)sharedFakeMPAnalyticsTracker;
- (void)advanceMPTimers:(NSTimeInterval)timeInterval;
- (NSMutableArray *)fakeTimers;
- (FakeMPTimer *)lastFakeMPTimerWithSelector:(SEL)selector;

#pragma mark - Third Party Integrations

#pragma mark iAd
@property (nonatomic, assign) ADBannerView *fakeADBannerView;
@property (nonatomic, assign) ADInterstitialAd *fakeADInterstitialAd;

#pragma mark Chartboost
@property (nonatomic, assign) Chartboost *fakeChartboost;

#pragma mark Google Ad Mob
@property (nonatomic, assign) GADRequest *fakeGADRequest;
@property (nonatomic, assign) GADBannerView *fakeGADBannerView;
@property (nonatomic, assign) GADInterstitial *fakeGADInterstitial;

#pragma mark Greystripe
@property (nonatomic, assign) FakeGSBannerAdView *fakeGSBannerAdView;
@property (nonatomic, assign) FakeGSFullscreenAd *fakeGSFullscreenAd;

#pragma mark InMobi
@property (nonatomic, assign) IMAdRequest *fakeIMAdRequest;
@property (nonatomic, assign) IMAdView *fakeIMAdView;
@property (nonatomic, assign) IMAdInterstitial *fakeIMAdInterstitial;

#pragma mark Millennial
@property (nonatomic, assign) FakeMMAdView *fakeMMAdView;
@property (nonatomic, assign) FakeMMInterstitial *fakeMMInterstitial;

@end
