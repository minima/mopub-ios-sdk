//
//  MPBannerAdDetailViewController.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPBannerAdDetailViewController.h"
#import "MPAdInfo.h"
#import "MPSampleAppInstanceProvider.h"

@interface MPBannerAdDetailViewController ()

@property (nonatomic, strong) MPAdInfo *info;
@property (nonatomic, strong) MPAdView *adView;
@property (nonatomic, assign) BOOL didLoadAd;

@end

@implementation MPBannerAdDetailViewController

- (id)initWithAdInfo:(MPAdInfo *)info
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.info = info;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Banner";
    self.titleLabel.text = self.info.title;
    self.IDLabel.text = self.info.ID;

    self.adView = [[MPSampleAppInstanceProvider sharedProvider] buildMPAdViewWithAdUnitID:self.info.ID
                                                                                     size:MOPUB_BANNER_SIZE];
    self.adView.delegate = self;
    self.adView.accessibilityLabel = @"banner";
    self.adView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.adViewContainer addSubview:self.adView];

    [self.spinner startAnimating];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (!self.didLoadAd) {
        [self.spinner startAnimating];
        [self.adView loadAd];
        self.didLoadAd = YES;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.adView rotateToOrientation:toInterfaceOrientation];
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark - <MPAdViewDelegate>

- (UIViewController *)viewControllerForPresentingModalView
{
    return self;
}

- (void)adViewDidLoadAd:(MPAdView *)view
{
    [self.spinner stopAnimating];
}

- (void)adViewDidFailToLoadAd:(MPAdView *)view
{
    [self.spinner stopAnimating];
    self.failLabel.hidden = NO;
}

#pragma mark - Legacy Custom Events

- (void)startLegacyBannerCustomEvent:(MPAdView *)view
{
    UIView *banner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    banner.backgroundColor = [UIColor redColor];

    UIGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTapCustomEventBanner:)];
    [banner addGestureRecognizer:tapRecognizer];

    [self.adView customEventDidLoadAd];
    [self.adView setAdContentView:banner];
    [self.spinner stopAnimating];
}

- (void)userDidTapCustomEventBanner:(UIGestureRecognizer *)recognizer
{
    [self.adView customEventActionWillBegin];
    recognizer.view.backgroundColor = [UIColor greenColor];

    [UIView animateWithDuration:1.0 animations:^{
        recognizer.view.backgroundColor = [UIColor redColor];
    } completion:^(BOOL finished) {
        [self.adView customEventActionDidEnd];
    }];
}

@end
