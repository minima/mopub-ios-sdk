//
//  MPInterstitialAdDetailViewController.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPInterstitialAdDetailViewController.h"
#import "MPAdInfo.h"
#import "MPSampleAppInstanceProvider.h"

@interface MPInterstitialAdDetailViewController ()

@property (nonatomic, strong) MPAdInfo *info;
@property (nonatomic, strong) MPInterstitialAdController *interstitial;

@end

@implementation MPInterstitialAdDetailViewController

- (id)initWithAdInfo:(MPAdInfo *)adInfo
{
    self = [super init];
    if (self) {
        self.info = adInfo;
    }
    return self;
}

- (void)viewDidLoad
{
    self.title = @"Interstitial";
    self.titleLabel.text = self.info.title;
    self.IDLabel.text = self.info.ID;
    self.showButton.hidden = YES;

    self.interstitial = [[MPSampleAppInstanceProvider sharedProvider] buildMPInterstitialAdControllerWithAdUnitID:self.info.ID];
    self.interstitial.delegate = self;

    [super viewDidLoad];
}

- (IBAction)didTapLoadButton:(id)sender
{
    [self.spinner startAnimating];
    self.showButton.hidden = YES;
    self.loadButton.enabled = NO;
    self.expireLabel.hidden = YES;
    self.failLabel.hidden = YES;
    self.willAppearLabel.alpha = 0.1;
    self.didAppearLabel.alpha = 0.1;
    self.willDisappearLabel.alpha = 0.1;
    self.didDisappearLabel.alpha = 0.1;
    [self.interstitial loadAd];
}

- (void)dealloc
{
    self.interstitial.delegate = nil;
}

- (IBAction)didTapShowButton:(id)sender
{
    [self.interstitial showFromViewController:self];
}

#pragma mark - <MPInterstitialAdControllerDelegate>

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial
{
    [self.spinner stopAnimating];
    self.showButton.hidden = NO;
    self.loadButton.enabled = YES;
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial
{
    self.failLabel.hidden = NO;
    self.loadButton.enabled = YES;
    [self.spinner stopAnimating];
}

- (void)interstitialDidExpire:(MPInterstitialAdController *)interstitial
{
    self.expireLabel.hidden = NO;
    self.loadButton.enabled = YES;
    self.showButton.hidden = YES;
    [self.spinner stopAnimating];
}

- (void)interstitialWillAppear:(MPInterstitialAdController *)interstitial
{
    self.willAppearLabel.alpha = 1.0;
}

- (void)interstitialDidAppear:(MPInterstitialAdController *)interstitial
{
    self.didAppearLabel.alpha = 1.0;
}

- (void)interstitialWillDisappear:(MPInterstitialAdController *)interstitial
{
    self.willDisappearLabel.alpha = 1.0;
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial
{
    self.showButton.hidden = YES;
    self.didDisappearLabel.alpha = 1.0;
}

@end
