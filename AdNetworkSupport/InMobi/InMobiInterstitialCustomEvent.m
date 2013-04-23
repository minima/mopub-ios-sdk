//
//  InMobiInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "InMobiInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPLogging.h"

@interface MPInstanceProvider (InMobiInterstitials)

- (IMAdInterstitial *)buildIMAdInterstitialWithDelegate:(id<IMAdInterstitialDelegate>)delegate appId:(NSString *)appId;
- (IMAdRequest *)buildIMAdRequest;

@end

@implementation MPInstanceProvider (InMobiInterstitials)

- (IMAdInterstitial *)buildIMAdInterstitialWithDelegate:(id<IMAdInterstitialDelegate>)delegate appId:(NSString *)appId;
{
    IMAdInterstitial *inMobiInterstitial = [[[IMAdInterstitial alloc] init] autorelease];
    inMobiInterstitial.delegate = delegate;
    inMobiInterstitial.imAppId = appId;
    return inMobiInterstitial;
}

- (IMAdRequest *)buildIMAdRequest
{
    return [IMAdRequest request];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////


#define kInMobiAppID    @"YOUR_INMOBI_APP_ID"

@interface InMobiInterstitialCustomEvent ()

@property (nonatomic, retain) IMAdInterstitial *inMobiInterstitial;

@end

@implementation InMobiInterstitialCustomEvent

@synthesize inMobiInterstitial = _inMobiInterstitial;

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Requesting InMobi interstitial");

    self.inMobiInterstitial = [[MPInstanceProvider sharedProvider] buildIMAdInterstitialWithDelegate:self
                                                                                               appId:kInMobiAppID];

    IMAdRequest *request = [[MPInstanceProvider sharedProvider] buildIMAdRequest];
    if (self.delegate.location) {
        [request setLocationWithLatitude:self.delegate.location.coordinate.latitude
                               longitude:self.delegate.location.coordinate.longitude
                                accuracy:self.delegate.location.horizontalAccuracy];
    }
    [self.inMobiInterstitial loadRequest:request];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.inMobiInterstitial presentInterstitialAnimated:YES];
}

- (void)dealloc
{
    [self.inMobiInterstitial setDelegate:nil];
    self.inMobiInterstitial = nil;
    [super dealloc];
}

#pragma mark - IMAdInterstitialDelegate

- (void)interstitialDidFinishRequest:(IMAdInterstitial *)ad
{
    MPLogInfo(@"InMobi interstitial did load");
    [self.delegate interstitialCustomEvent:self didLoadAd:ad];
}

- (void)interstitial:(IMAdInterstitial *)ad didFailToReceiveAdWithError:(IMAdError *)error
{
    MPLogInfo(@"InMobi banner did fail with error: %@", error.localizedDescription);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)interstitialWillPresentScreen:(IMAdInterstitial *)ad
{
    MPLogInfo(@"InMobi interstitial will present");
    [self.delegate interstitialCustomEventWillAppear:self];

    // InMobi doesn't seem to have a separate callback for the "did appear" event, so we
    // signal that manually.
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitial:(IMAdInterstitial *)ad didFailToPresentScreenWithError:(IMAdError *)error
{
    MPLogInfo(@"InMobi interstitial failed to present with error: %@", error.localizedDescription);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)interstitialWillDismissScreen:(IMAdInterstitial *)ad
{
    MPLogInfo(@"InMobi interstitial will dismiss");
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialDidDismissScreen:(IMAdInterstitial *)ad
{
    MPLogInfo(@"InMobi interstitial did dismiss");
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialWillLeaveApplication:(IMAdInterstitial *)ad
{
    MPLogInfo(@"InMobi interstitial will leave application");
    // InMobi doesn't seem to have an explicit callback for tap events. However, leaving the
    // application is generally an indicator of a user tap, so we can use this callback
    // to signal the tap event.
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

@end
