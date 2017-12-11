//
//  MPBannerCustomEventAdapter+Testing.h
//  MoPubSDKTests
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPBannerCustomEventAdapter.h"

@interface MPBannerCustomEventAdapter (Testing)

@property (nonatomic, strong) MPBannerCustomEvent *bannerCustomEvent;
@property (nonatomic, strong) MPAdConfiguration *configuration;
@property (nonatomic, assign) BOOL hasTrackedImpression;

- (void)loadAdWithConfiguration:(MPAdConfiguration *)configuration customEvent:(MPBannerCustomEvent *)customEvent;
- (void)setHasTrackedImpression:(BOOL)hasTrackedImpression;

- (BOOL)shouldTrackImpressionOnDisplay;

@end
