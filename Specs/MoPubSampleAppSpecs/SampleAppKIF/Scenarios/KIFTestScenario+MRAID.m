//
//  KIFTestScenario+MRAID.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario+MRAID.h"
#import "KIFTestStep.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MPInterstitialAdDetailViewController.h"

@implementation KIFTestScenario (MRAID)

+ (id)scenarioForMRAIDInterstitialWithVideo
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that an MRAID interstitial can play video"];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"MRAID Interstitial" inSection:@"Interstitial Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                            atIndexPath:indexPath]];

    // Load and display the MRAID interstitial.
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Load"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Show"]];

    // When it appears on-screen, tap the "Video" link.
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Close Interstitial Ad"]];
    [scenario addStep:[KIFTestStep stepToTapLink:@"Video" webViewClassName:@"UIWebView"]];

    // Check that a video player is displayed, and then dismiss it.
    [scenario addStep:[KIFTestStep stepToVerifyPresentationOfViewControllerClass:[MPMoviePlayerViewController class]]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Done"]];

    // Then, dismiss the interstitial itself.
    [scenario addStep:[KIFTestStep stepToWaitForViewWithAccessibilityLabel:@"Close Interstitial Ad"]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Close Interstitial Ad"]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenceOfViewWithAccessibilityLabel:@"Close Interstitial Ad"]];

    // Return to the main table view.
    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

@end
