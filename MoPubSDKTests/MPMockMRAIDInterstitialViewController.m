//
//  MPMockMRAIDInterstitialViewController.m
//  MoPubSDK
//
//  Copyright © 2016 MoPub. All rights reserved.
//

#import "MPMockMRAIDInterstitialViewController.h"

@interface MPMockMRAIDInterstitialViewController ()

@end

@implementation MPMockMRAIDInterstitialViewController

- (instancetype)init {
    return [self initWithAdConfiguration:nil];
}

- (void)startLoading {
    if ([self.delegate respondsToSelector:@selector(interstitialDidLoadAd:)]) {
        [self.delegate interstitialDidLoadAd:self];
    }
}

- (void)simulateDismiss {
    if ([self.delegate respondsToSelector:@selector(interstitialDidDisappear:)]) {
        [self.delegate interstitialDidDisappear:self];
    }
}

- (void)simulateTap {
    if ([self.delegate respondsToSelector:@selector(interstitialDidReceiveTapEvent:)]) {
        [self.delegate interstitialDidReceiveTapEvent:self];
    }
}

@end
