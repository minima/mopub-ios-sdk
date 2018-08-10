//
//  MPInterstitialCustomEventAdapter+Testing.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPInterstitialCustomEventAdapter.h"

@interface MPInterstitialCustomEventAdapter (Testing)

- (void)interstitialCustomEvent:(MPInterstitialCustomEvent *)customEvent didLoadAd:(id)ad;
- (void)startTimeoutTimer;

@property (nonatomic, strong) MPAdConfiguration * configuration;
@property (nonatomic, assign) BOOL hasTrackedImpression;

@end
