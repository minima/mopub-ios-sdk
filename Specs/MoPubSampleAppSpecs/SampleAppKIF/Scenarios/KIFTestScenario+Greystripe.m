//
//  KIFTestScenario+Greystripe.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario+Greystripe.h"
#import <objc/runtime.h>

@implementation KIFTestScenario (Greystripe)

+ (KIFTestScenario *)scenarioForGreystripeBanner
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a Greystripe Banner ad works."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Greystripe Banner" inSection:@"Banner Ads"];

    // Greystripe 4.2.1 has a bug in which the first ad request always fails.
    // We'll wait for it to fail, then try again.
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                             atIndexPath:indexPath]];

    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"banner"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"failLabel"]];

    // Trying again.
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                             atIndexPath:indexPath]];
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"banner"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"GSMobileBannerAdView"]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"banner"]];
    [scenario addStep:[KIFTestStep stepToLogClickForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"GSBrowserView"]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Done"]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenceOfViewWithClassName:@"GSBrowserView"]];
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

+ (KIFTestScenario *)scenarioForGreystripeInterstitial
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a Greystripe interstitial ad works."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Greystripe Interstitial" inSection:@"Interstitial Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                     atIndexPath:indexPath]];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Load"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Show"]];
    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"GSFullscreenAdView"]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToPerformBlock:^{
        // We can't get KIF to tap on Greystripe's webview, so instead, we grab the controller and tell it to go away
        id gsFullScreenAdViewController = [KIFHelper topMostViewController];
        [gsFullScreenAdViewController dismissAnimated:YES];
    }]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenceOfViewWithClassName:@"GSFullscreenAdView"]];

    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

@end
