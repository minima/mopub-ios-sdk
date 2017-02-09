//
//  MPMoPubRewardedPlayableCustomEvent+Testing.h
//  MoPubSDK
//
//  Copyright © 2016 MoPub. All rights reserved.
//

#import "MPMoPubRewardedPlayableCustomEvent.h"
#import "MPMRAIDInterstitialViewController.h"
#import "MPCountdownTimerView.h"

@interface MPMoPubRewardedPlayableCustomEvent (Testing)
@property (nonatomic, readonly) BOOL isCountdownActive;
@property (nonatomic, strong) MPMRAIDInterstitialViewController *interstitial;
@property (nonatomic, strong) MPCountdownTimerView *timerView;

- (instancetype)initWithInterstitial:(MPMRAIDInterstitialViewController *)interstitial;

@end
