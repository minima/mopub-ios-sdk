//
//  FakeIMAdView.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeIMAdView.h"

@implementation FakeIMAdView

- (void)loadIMAdRequest:(IMAdRequest *)request
{
    self.loadedRequest = request;
}

- (void)simulateLoadingAd
{
    [self.delegate adViewDidFinishRequest:self];
}

- (void)simulateFailingToLoad
{
    [self.delegate adView:self didFailRequestWithError:nil];
}

- (void)simulateUserTap
{
    [self.delegate adViewWillPresentScreen:self];
}

- (void)simulateUserEndingInteraction
{
    [self.delegate adViewDidDismissScreen:self];
}

- (void)simulateUserLeavingApplication
{
    [self.delegate adViewWillLeaveApplication:self];
}

@end
