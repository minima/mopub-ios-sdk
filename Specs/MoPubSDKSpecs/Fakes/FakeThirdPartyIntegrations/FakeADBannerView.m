//
//  FakeADBannerView.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeADBannerView.h"

@implementation FakeADBannerView

- (instancetype)initWithAdType:(ADAdType)type
{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

- (void)simulateLoadingAd
{
    self.bannerLoaded = YES;
    [self.delegate bannerViewDidLoadAd:self.masquerade];
}

- (void)simulateFailingToLoad
{
    self.bannerLoaded = NO;
    [self.delegate bannerView:self.masquerade didFailToReceiveAdWithError:nil];
}

- (void)simulateUserInteraction
{
    [self.delegate bannerViewActionShouldBegin:self.masquerade willLeaveApplication:NO];
}

- (void)simulateUserDismissingAd
{
    [self.delegate bannerViewActionDidFinish:self.masquerade];
}

- (void)simulateUserLeavingApplication
{
    [self.delegate bannerViewActionShouldBegin:self.masquerade willLeaveApplication:YES];
}

- (ADBannerView *)masquerade
{
    return (ADBannerView *)self;
}

- (void)setDelegate:(id<ADBannerViewDelegate>)delegate
{
    _delegate = delegate;
}

@end
