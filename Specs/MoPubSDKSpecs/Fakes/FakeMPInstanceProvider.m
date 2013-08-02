//
//  FakeMPInstanceProvider.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMPInstanceProvider.h"
#import "MPAdWebView.h"
#import "FakeMPTimer.h"

@interface MPInstanceProvider (ThirdPartyAdditions)

#pragma mark - Third Party Integrations Category Interfaces
#pragma mark iAd
- (ADInterstitialAd *)buildADInterstitialAd;
- (ADBannerView *)buildADBannerView;

#pragma mark Chartboost
- (Chartboost *)buildChartboost;

#pragma mark Google Ad Mob
- (GADRequest *)buildGADBannerRequest;
- (GADBannerView *)buildGADBannerViewWithFrame:(CGRect)frame;
- (GADRequest *)buildGADInterstitialRequest;
- (GADInterstitial *)buildGADInterstitialAd;

#pragma mark Greystripe
- (GSBannerAdView *)buildGreystripeBannerAdViewWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID size:(CGSize)size;
- (GSFullscreenAd *)buildGSFullscreenAdWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID;

#pragma mark InMobi
- (IMAdRequest *)buildIMAdBannerRequest;
- (IMAdView *)buildIMAdViewWithFrame:(CGRect)frame appId:(NSString *)appId adSize:(int)adSize;
- (IMAdRequest *)buildIMAdInterstitialRequest;
- (IMAdInterstitial *)buildIMAdInterstitialWithDelegate:(id<IMAdInterstitialDelegate>)delegate appId:(NSString *)appID;

#pragma mark Millennial
- (MMAdView *)buildMMAdViewWithFrame:(CGRect)frame apid:(NSString *)apid rootViewController:(UIViewController *)controller;
- (id)MMInterstitial;

@end


@interface FakeMPInstanceProvider ()

@property (nonatomic, assign) NSMutableArray *fakeTimers;

@end

@implementation FakeMPInstanceProvider

- (id)init
{
    self = [super init];
    if (self) {
        self.fakeTimers = [NSMutableArray array];
    }
    return self;
}

- (id)returnFake:(id)fake orCall:(IDReturningBlock)block
{
    if (fake) {
        return fake;
    } else {
        return block();
    }
}

#pragma mark - Fetching Ads

- (NSString *)userAgent
{
    return @"FAKE_TEST_USER_AGENT_STRING";
}

- (MPAdServerCommunicator *)buildMPAdServerCommunicatorWithDelegate:(id<MPAdServerCommunicatorDelegate>)delegate
{
    self.lastFakeMPAdServerCommunicator = [[[FakeMPAdServerCommunicator alloc] initWithDelegate:delegate] autorelease];
    return self.lastFakeMPAdServerCommunicator;
}

#pragma mark - Banners

- (MPBaseBannerAdapter *)buildBannerAdapterForConfiguration:(MPAdConfiguration *)configuration
                                                   delegate:(id<MPBannerAdapterDelegate>)delegate
{
    if (self.fakeBannerAdapter) {
        self.fakeBannerAdapter.delegate = delegate;
        return self.fakeBannerAdapter;
    } else {
        return [super buildBannerAdapterForConfiguration:configuration
                                                delegate:delegate];
    }
}

- (MPBannerCustomEvent *)buildBannerCustomEventFromCustomClass:(Class)customClass
                                                      delegate:(id<MPBannerCustomEventDelegate>)delegate
{
    if (self.fakeBannerCustomEvent) {
        self.fakeBannerCustomEvent.delegate = delegate;
        return self.fakeBannerCustomEvent;
    }

    return [super buildBannerCustomEventFromCustomClass:customClass delegate:delegate];
}

#pragma mark - Interstitials
- (MPInterstitialAdManager *)buildMPInterstitialAdManagerWithDelegate:(id<MPInterstitialAdManagerDelegate>)delegate
{
    return [self returnFake:self.fakeMPInterstitialAdManager
                     orCall:^{
                         return [super buildMPInterstitialAdManagerWithDelegate:delegate];
                     }];
}

- (MPBaseInterstitialAdapter *)buildInterstitialAdapterForConfiguration:(MPAdConfiguration *)configuration
                                                               delegate:(id<MPInterstitialAdapterDelegate>)delegate
{
    if (self.fakeInterstitialAdapter) {
        self.fakeInterstitialAdapter.delegate = delegate;
        return self.fakeInterstitialAdapter;
    } else {
        return [super buildInterstitialAdapterForConfiguration:configuration
                                                      delegate:delegate];
    }
}

- (MPInterstitialCustomEvent *)buildInterstitialCustomEventFromCustomClass:(Class)customClass
                                                                  delegate:(id<MPInterstitialCustomEventDelegate>)delegate
{
    if (self.fakeInterstitialCustomEvent) {
        self.fakeInterstitialCustomEvent.delegate = delegate;
        return self.fakeInterstitialCustomEvent;
    }

    return [super buildInterstitialCustomEventFromCustomClass:customClass delegate:delegate];
}

- (MPHTMLInterstitialViewController *)buildMPHTMLInterstitialViewControllerWithDelegate:(id<MPInterstitialViewControllerDelegate>)delegate orientationType:(MPInterstitialOrientationType)type customMethodDelegate:(id)customMethodDelegate
{
    return [self returnFake:self.fakeMPHTMLInterstitialViewController
                     orCall:^{
                         return [super buildMPHTMLInterstitialViewControllerWithDelegate:delegate orientationType:type customMethodDelegate:customMethodDelegate];
                     }];
}

- (MPMRAIDInterstitialViewController *)buildMPMRAIDInterstitialViewControllerWithDelegate:(id<MPInterstitialViewControllerDelegate>)delegate configuration:(MPAdConfiguration *)configuration
{
    return [self returnFake:self.fakeMPMRAIDInterstitialViewController
                     orCall:^{
                         return [super buildMPMRAIDInterstitialViewControllerWithDelegate:delegate
                                                                            configuration:configuration];
                     }];
}

#pragma mark - HTML Ads

- (MPAdWebView *)buildMPAdWebViewWithFrame:(CGRect)frame delegate:(id<UIWebViewDelegate>)delegate
{
    if (self.fakeMPAdWebView) {
        self.fakeMPAdWebView.frame = frame;
        self.fakeMPAdWebView.delegate = delegate;
        return self.fakeMPAdWebView;
    } else {
        return [super buildMPAdWebViewWithFrame:frame delegate:delegate];
    }
}

- (MPAdWebViewAgent *)buildMPAdWebViewAgentWithAdWebViewFrame:(CGRect)frame delegate:(id<MPAdWebViewAgentDelegate>)delegate customMethodDelegate:(id)customMethodDelegate
{
    return [self returnFake:self.fakeMPAdWebViewAgent
                     orCall:^{
                         return [super buildMPAdWebViewAgentWithAdWebViewFrame:frame
                                                                      delegate:delegate
                                                          customMethodDelegate:customMethodDelegate];
                     }];
}

#pragma mark - URL Handling

- (MPURLResolver *)buildMPURLResolver
{
    return [self returnFake:self.fakeMPURLResolver
                     orCall:^{
                         return [super buildMPURLResolver];
                     }];
}

- (MPAdDestinationDisplayAgent *)buildMPAdDestinationDisplayAgentWithDelegate:(id<MPAdDestinationDisplayAgentDelegate>)delegate
{
    return [self returnFake:self.fakeMPAdDestinationDisplayAgent
                     orCall:^{
                         return [super buildMPAdDestinationDisplayAgentWithDelegate:delegate];
                     }];
}

#pragma mark - Utilities

- (MPReachability *)sharedMPReachability
{
    return [self returnFake:self.fakeMPReachability
                     orCall:^id{
                         return [super sharedMPReachability];
                     }];
}

- (CTCarrier *)buildCTCarrier;
{
    return [self returnFake:self.fakeCTCarrier
                     orCall:^id{
                         return [super buildCTCarrier];
                     }];
}

- (MPAnalyticsTracker *)sharedMPAnalyticsTracker
{
    return [self sharedFakeMPAnalyticsTracker];
}

- (FakeMPAnalyticsTracker *)sharedFakeMPAnalyticsTracker
{
    return [self singletonForClass:[MPAnalyticsTracker class] provider:^id{
        return [[[FakeMPAnalyticsTracker alloc] init] autorelease];
    }];
}

- (MPTimer *)buildMPTimerWithTimeInterval:(NSTimeInterval)seconds target:(id)target selector:(SEL)selector repeats:(BOOL)repeats
{
    MPTimer *fakeTimer = [FakeMPTimer timerWithTimeInterval:seconds target:target selector:selector repeats:repeats];
    [self.fakeTimers addObject:fakeTimer];
    return fakeTimer;
}

- (void)advanceMPTimers:(NSTimeInterval)timeInterval
{
    NSTimeInterval delta = 1;
    NSTimeInterval advanceBy = 0;
    while (timeInterval > 0) {
        advanceBy = delta < timeInterval ? delta : timeInterval;
        for (FakeMPTimer *timer in self.fakeTimers) {
            [timer advanceTime:advanceBy];
        }
        timeInterval -= advanceBy;
    }
}

- (FakeMPTimer *)lastFakeMPTimerWithSelector:(SEL)selector
{
    int numTimers = [self.fakeTimers count];
    for (int i = numTimers - 1; i >= 0; i--) {
        if ([self.fakeTimers[i] selector] == selector) {
            return self.fakeTimers[i];
        }
    }

    return nil;
}

#pragma mark - Third Party Integrations

#pragma mark iAd

- (ADBannerView *)buildADBannerView
{
    return [self returnFake:self.fakeADBannerView
                     orCall:^{
                         return [super buildADBannerView];
                     }];
}

- (ADInterstitialAd *)buildADInterstitialAd
{
    return [self returnFake:self.fakeADInterstitialAd
                     orCall:^{
                         return [super buildADInterstitialAd];
                     }];
}

#pragma mark Chartboost

- (Chartboost *)buildChartboost
{
    return [self returnFake:self.fakeChartboost
                     orCall:^{
                         return [super buildChartboost];
                     }];
}

#pragma mark Google Ad Mob

- (GADRequest *)buildGADBannerRequest
{
    return [self returnFake:self.fakeGADBannerRequest
                     orCall:^{
                         return [super buildGADBannerRequest];
                     }];
}

- (GADBannerView *)buildGADBannerViewWithFrame:(CGRect)frame
{
    return [self returnFake:self.fakeGADBannerView
                     orCall:^{
                         return [super buildGADBannerViewWithFrame:frame];
                     }];
}

- (GADRequest *)buildGADInterstitialRequest
{
    return [self returnFake:self.fakeGADInterstitialRequest
                     orCall:^{
                         return [super buildGADInterstitialRequest];
                     }];
}

- (GADInterstitial *)buildGADInterstitialAd
{
    return [self returnFake:self.fakeGADInterstitial
                     orCall:^{
                         return [super buildGADInterstitialAd];
                     }];
}

#pragma mark Greystripe

- (GSBannerAdView *)buildGreystripeBannerAdViewWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID size:(CGSize)size;
{
    if (self.fakeGSBannerAdView) {
        self.fakeGSBannerAdView.delegate = delegate;
        self.fakeGSBannerAdView.GUID = GUID;
        return self.fakeGSBannerAdView;
    } else {
        return [super buildGreystripeBannerAdViewWithDelegate:delegate GUID:GUID size:size];
    }
}

- (GSFullscreenAd *)buildGSFullscreenAdWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID
{
    if (self.fakeGSFullscreenAd) {
        self.fakeGSFullscreenAd.delegate = delegate;
        self.fakeGSFullscreenAd.GUID = GUID;
        return self.fakeGSFullscreenAd;
    } else {
        return [super buildGSFullscreenAdWithDelegate:delegate GUID:GUID];
    }
}

#pragma mark InMobi

- (IMAdRequest *)buildIMAdBannerRequest
{
    return [self returnFake:self.fakeIMAdBannerRequest
                     orCall:^{
                         return [super buildIMAdBannerRequest];
                     }];
}

- (IMAdView *)buildIMAdViewWithFrame:(CGRect)frame appId:(NSString *)appId adSize:(int)adSize
{
    if (self.fakeIMAdView) {
        self.fakeIMAdView.frame = frame;
        self.fakeIMAdView.imAppId = appId;
        self.fakeIMAdView.imAdSize = adSize;
        return self.fakeIMAdView;
    }
    return [super buildIMAdViewWithFrame:frame appId:appId adSize:adSize];
}

- (IMAdRequest *)buildIMAdInterstitialRequest
{
    return [self returnFake:self.fakeIMAdInterstitialRequest
                     orCall:^{
                         return [super buildIMAdInterstitialRequest];
                     }];
}

- (IMAdInterstitial *)buildIMAdInterstitialWithDelegate:(id<IMAdInterstitialDelegate>)delegate appId:(NSString *)appId;
{
    if (self.fakeIMAdInterstitial) {
        self.fakeIMAdInterstitial.imAppId = appId;
        self.fakeIMAdInterstitial.delegate = delegate;
        return self.fakeIMAdInterstitial;
    }
    return [super buildIMAdInterstitialWithDelegate:delegate appId:appId];
}

#pragma mark Millennial

- (MMAdView *)buildMMAdViewWithFrame:(CGRect)frame apid:(NSString *)apid rootViewController:(UIViewController *)controller
{
    if (self.fakeMMAdView) {
        self.fakeMMAdView.frame = frame;
        self.fakeMMAdView.apid = apid;
        self.fakeMMAdView.rootViewController = controller;
        return self.fakeMMAdView.masquerade;
    }

    return [super buildMMAdViewWithFrame:frame apid:apid rootViewController:controller];
}

- (id)MMInterstitial
{
    if (self.fakeMMInterstitial) {
        return self.fakeMMInterstitial;
    } else {
        return [super MMInterstitial];
    }
}

@end
