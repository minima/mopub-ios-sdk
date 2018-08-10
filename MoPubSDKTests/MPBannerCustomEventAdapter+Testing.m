//
//  MPBannerCustomEventAdapter+Testing.m
//  MoPubSDKTests
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPBannerCustomEventAdapter+Testing.h"
#import "MPBannerCustomEvent.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
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
#pragma clang diagnostic pop
