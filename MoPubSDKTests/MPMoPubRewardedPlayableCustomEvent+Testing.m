//
//  MPMoPubRewardedPlayableCustomEvent+Testing.m
//  MoPubSDK
//
//  Copyright © 2016 MoPub. All rights reserved.
//

#import "MPMoPubRewardedPlayableCustomEvent+Testing.h"

@implementation MPMoPubRewardedPlayableCustomEvent (Testing)
@dynamic interstitial;
@dynamic timerView;

- (instancetype)initWithInterstitial:(MPMRAIDInterstitialViewController *)interstitial {
    if (self = [super init]) {
        self.interstitial = interstitial;
    }

    return self;
}

- (BOOL)isCountdownActive {
    return self.timerView.isActive;
}

@end
