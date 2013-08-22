//
//  MPKIFTestController.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPKIFTestController.h"
#import "KIFTestScenario+StoreKitScenario.h"
#import "KIFTestScenario+Millennial.h"
#import "KIFTestScenario+GAD.h"
#import "KIFTestScenario+Chartboost.h"
#import "KIFTestScenario+Greystripe.h"
#import "KIFTestScenario+InMobi.h"
#import "KIFTestScenario+HTML.h"
#import "KIFTestScenario+MRAID.h"

@implementation MPKIFTestController

- (BOOL)flakyTestMode
{
    return getenv("KIF_FLAKY_TESTS") ? YES : NO;
}

- (void)initializeScenarios
{
    [KIFTestStep setDefaultTimeout:20];

    [self addScenario:[KIFTestScenario scenarioForBannerAdWithStoreKitLink]];
    [self addScenario:[KIFTestScenario scenarioForBannerAdWithInvalidStoreKitLink]];
    [self addScenario:[KIFTestScenario scenarioForClickToSafariBannerAd]];
    [self addScenario:[KIFTestScenario scenarioForClickToSafariMRAIDAd]];
    [self addScenario:[KIFTestScenario scenarioForMillennialBanner]];
    [self addScenario:[KIFTestScenario scenarioForGADBanner]];
    [self addScenario:[KIFTestScenario scenarioForGreystripeBanner]];
    [self addScenario:[KIFTestScenario scenarioForInMobiBanner]];
    [self addScenario:[KIFTestScenario scenarioForInterstitialAdWithStoreKitLink]];
    [self addScenario:[KIFTestScenario scenarioForMillennialInterstitial]];
    [self addScenario:[KIFTestScenario scenarioForGADInterstitial]];
    [self addScenario:[KIFTestScenario scenarioForGreystripeInterstitial]];
    [self addScenario:[KIFTestScenario scenarioForInMobiInterstitial]];
    [self addScenario:[KIFTestScenario scenarioForChartboostInterstitial]];
    [self addScenario:[KIFTestScenario scenarioForMultipleChartboostInterstitials]];

// TODO: Add this scenario again once the MRAID tag is on the front-end and not just local.
//    [self addScenario:[KIFTestScenario scenarioForMRAIDInterstitialWithVideo]];
}

@end
