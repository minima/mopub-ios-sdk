//
//  MPInterstitialCustomEventAdapter+Testing.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPInterstitialCustomEventAdapter.h"

@interface MPInterstitialCustomEventAdapter (Testing)

- (void)interstitialCustomEvent:(MPInterstitialCustomEvent *)customEvent didLoadAd:(id)ad;

@property (nonatomic, assign) BOOL hasTrackedImpression;

@end
