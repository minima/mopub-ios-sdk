//
//  MPMRAIDInterstitialViewController.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPMRAIDInterstitialViewController.h"
#import "MPInstanceProvider.h"
#import "MPAdConfiguration.h"
#import "MRController.h"

@interface MPMRAIDInterstitialViewController () <MRControllerDelegate>

@property (nonatomic, strong) MPAdConfiguration *configuration;
@property (nonatomic, strong) MRController *mraidController;
@property (nonatomic, strong) UIView *interstitialView;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPMRAIDInterstitialViewController


- (id)initWithAdConfiguration:(MPAdConfiguration *)configuration
{
    self = [super init];
    if (self) {
        CGFloat width = MAX(configuration.preferredSize.width, 1);
        CGFloat height = MAX(configuration.preferredSize.height, 1);
        CGRect frame = CGRectMake(0, 0, width, height);
        self.mraidController = [[MPInstanceProvider sharedProvider] buildInterstitialMRControllerWithFrame:frame delegate:self];

        self.configuration = configuration;
        self.orientationType = [self.configuration orientationType];
    }
    return self;
}

#pragma mark - Public

- (void)startLoading
{
    [self.mraidController loadAdWithConfiguration:self.configuration];
}

- (void)willPresentInterstitial
{
    [self.mraidController disableRequestHandling];
    if ([self.delegate respondsToSelector:@selector(interstitialWillAppear:)]) {
        [self.delegate interstitialWillAppear:self];
    }
}

- (void)didPresentInterstitial
{
    [self.mraidController enableRequestHandling];
    if ([self.delegate respondsToSelector:@selector(interstitialDidAppear:)]) {
        [self.delegate interstitialDidAppear:self];
    }
}

- (void)willDismissInterstitial
{
    [self.mraidController disableRequestHandling];
    if ([self.delegate respondsToSelector:@selector(interstitialWillDisappear:)]) {
        [self.delegate interstitialWillDisappear:self];
    }
}

- (void)didDismissInterstitial
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidDisappear:)]) {
        [self.delegate interstitialDidDisappear:self];
    }
}

#pragma mark - MRControllerDelegate

- (CLLocation *)location
{
    return [self.delegate location];
}

- (NSString *)adUnitId
{
    return [self.delegate adUnitId];
}

- (MPAdConfiguration *)adConfiguration
{
    return self.configuration;
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

- (void)adDidLoad:(UIView *)adView
{
    [self.interstitialView removeFromSuperview];

    self.interstitialView = adView;
    self.interstitialView.frame = self.view.bounds;
    self.interstitialView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.interstitialView];

    if ([self.delegate respondsToSelector:@selector(interstitialDidLoadAd:)]) {
        [self.delegate interstitialDidLoadAd:self];
    }
}

- (void)adDidFailToLoad:(UIView *)adView
{
    if ([self.delegate respondsToSelector:@selector(interstitialDidFailToLoadAd:)]) {
        [self.delegate interstitialDidFailToLoadAd:self];
    }
}

- (void)adWillClose:(UIView *)adView
{
    [self dismissInterstitialAnimated:YES];
}

- (void)adDidClose:(UIView *)adView
{
    // TODO:
}

- (void)appShouldSuspendForAd:(UIView *)adView
{
    [self.delegate interstitialDidReceiveTapEvent:self];
}

- (void)appShouldResumeFromAd:(UIView *)adView
{

}

@end
