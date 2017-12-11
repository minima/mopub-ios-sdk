//
//  MPBannerCustomEventAdapter+Testing.m
//  MoPubSDKTests
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPBannerCustomEventAdapter+Testing.h"
#import "MPBannerCustomEvent.h"

@implementation MPBannerCustomEventAdapter (Testing)

@dynamic configuration;
@dynamic bannerCustomEvent;
@dynamic hasTrackedImpression;

- (void)loadAdWithConfiguration:(MPAdConfiguration *)configuration customEvent:(MPBannerCustomEvent *)customEvent {
    self.configuration = configuration;
    self.bannerCustomEvent = customEvent;
    self.hasTrackedImpression = NO;
}

@end
