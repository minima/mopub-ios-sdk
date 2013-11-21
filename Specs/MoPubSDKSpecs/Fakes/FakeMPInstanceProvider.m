//
//  FakeMPInstanceProvider.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMPInstanceProvider.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MPAdWebView.h"
#import "FakeMPTimer.h"
#import "MRJavaScriptEventEmitter.h"
#import "MRImageDownloader.h"
#import "MRBundleManager.h"

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
- (IMBanner *)buildIMBannerWithFrame:(CGRect)frame appId:(NSString *)appId adSize:(int)adSize;
- (IMInterstitial *)buildIMInterstitialWithDelegate:(id<IMInterstitialDelegate>)delegate appId:(NSString *)appId;

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

#pragma mark - MRAID

- (MRAdView *)buildMRAdViewWithFrame:(CGRect)frame
                     allowsExpansion:(BOOL)allowsExpansion
                    closeButtonStyle:(MRAdViewCloseButtonStyle)style
                       placementType:(MRAdViewPlacementType)type
                            delegate:(id<MRAdViewDelegate>)delegate
{
    if (self.fakeMRAdView != nil) {
        self.fakeMRAdView.delegate = delegate;
        return self.fakeMRAdView;
    } else {
        return [super buildMRAdViewWithFrame:frame allowsExpansion:allowsExpansion closeButtonStyle:style placementType:type delegate:delegate];
    }
}

- (MRBundleManager *)buildMRBundleManager
{
    return [self returnFake:self.fakeMRBundleManager
                     orCall:^{
                         return [super buildMRBundleManager];
                     }];
}

- (UIWebView *)buildUIWebViewWithFrame:(CGRect)frame
{
    return [self returnFake:self.fakeUIWebView orCall:^id{
        return [super buildUIWebViewWithFrame:frame];
    }];
}

- (MRJavaScriptEventEmitter *)buildMRJavaScriptEventEmitterWithWebView:(UIWebView *)webView
{
    return [self returnFake:self.fakeMRJavaScriptEventEmitter
                     orCall:^{
                        return [super buildMRJavaScriptEventEmitterWithWebView:webView];
                     }];
}

- (MRCalendarManager *)buildMRCalendarManagerWithDelegate:(id<MRCalendarManagerDelegate>)delegate
{
    return [self returnFake:self.fakeMRCalendarManager
                     orCall:^{
                         return [super buildMRCalendarManagerWithDelegate:delegate];
                     }];
}

- (EKEventEditViewController *)buildEKEventEditViewControllerWithEditViewDelegate:(id <EKEventEditViewDelegate>)editViewDelegate
{
    if (self.fakeEKEventEditViewController) {
        self.fakeEKEventEditViewController.editViewDelegate = editViewDelegate;
        return self.fakeEKEventEditViewController;
    } else {
        return [super buildEKEventEditViewControllerWithEditViewDelegate:editViewDelegate];
    }
}

- (EKEventStore *)buildEKEventStore
{
    return [self returnFake:self.fakeEKEventStore
                     orCall:^{
                        return [super buildEKEventStore];
                     }];
}

- (MRPictureManager *)buildMRPictureManagerWithDelegate:(id<MRPictureManagerDelegate>)delegate
{
    return [self returnFake:self.fakeMRPictureManager
                     orCall:^{
                         return [super buildMRPictureManagerWithDelegate:delegate];
                     }];
}

- (MRImageDownloader *)buildMRImageDownloaderWithDelegate:(id<MRImageDownloaderDelegate>)delegate
{
    if (self.fakeImageDownloader) {
        self.fakeImageDownloader.delegate = delegate;
        return self.fakeImageDownloader;
    } else {
        return [super buildMRImageDownloaderWithDelegate:delegate];
    }

}

- (MRVideoPlayerManager *)buildMRVideoPlayerManagerWithDelegate:(id<MRVideoPlayerManagerDelegate>)delegate
{
    return [self returnFake:self.fakeMRVideoPlayerManager
                     orCall:^{
                         return [super buildMRVideoPlayerManagerWithDelegate:delegate];
                     }];
}

- (MPMoviePlayerViewController *)buildMPMoviePlayerViewControllerWithURL:(NSURL *)URL
{
    return [self returnFake:self.fakeMoviePlayerViewController
                     orCall:^{
                         return [super buildMPMoviePlayerViewControllerWithURL:URL];
                     }];
}

#pragma mark - Utilities

- (MPAdAlertManager *)buildMPAdAlertManagerWithDelegate:(id<MPAdAlertManagerDelegate>)delegate
{
    if (self.fakeAdAlertManager != nil) {
        self.fakeAdAlertManager.delegate = delegate;
        return self.fakeAdAlertManager;
    } else {
        return [super buildMPAdAlertManagerWithDelegate:delegate];
    }
}

- (MPAdAlertGestureRecognizer *)buildMPAdAlertGestureRecognizerWithTarget:(id)target action:(SEL)action
{
    if (self.fakeAdAlertGestureRecognizer != nil) {
        [self.fakeAdAlertGestureRecognizer addTarget:target action:action];
        return self.fakeAdAlertGestureRecognizer;
    } else {
        return [super buildMPAdAlertGestureRecognizerWithTarget:target action:action];
    }
}

- (NSOperationQueue *)sharedOperationQueue
{
    return [self returnFake:self.fakeOperationQueue
                     orCall:^{
                        return [super sharedOperationQueue];
                     }];
}

- (MPReachability *)sharedMPReachability
{
    return [self returnFake:self.fakeMPReachability
                     orCall:^id{
                         return [super sharedMPReachability];
                     }];
}

- (NSDictionary *)sharedCarrierInfo
{
    return [self returnFake:self.fakeCarrierInfo
                     orCall:^id{
                         return [super sharedCarrierInfo];
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

- (IMBanner *)buildIMBannerWithFrame:(CGRect)frame appId:(NSString *)appId adSize:(int)adSize
{
    if (self.fakeIMAdView) {
        self.fakeIMAdView.frame = frame;
        self.fakeIMAdView.appId = appId;
        self.fakeIMAdView.adSize = adSize;
        return self.fakeIMAdView;
    }
    return [super buildIMBannerWithFrame:frame appId:appId adSize:adSize];
}

- (IMInterstitial *)buildIMInterstitialWithDelegate:(id<IMInterstitialDelegate>)delegate appId:(NSString *)appId
{
    if (self.fakeIMAdInterstitial) {
        self.fakeIMAdInterstitial.appId = appId;
        self.fakeIMAdInterstitial.delegate = delegate;
        return self.fakeIMAdInterstitial;
    }
    return [super buildIMInterstitialWithDelegate:delegate appId:appId];
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
