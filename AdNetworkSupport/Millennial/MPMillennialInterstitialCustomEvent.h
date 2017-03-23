//
//  MPMillennialInterstitialCustomEvent.h
//
//  Copyright (c) 2015 Millennial Media, Inc. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MoPub.h"
#endif

#import <MMAdSDK/MMAdSDK.h>

/*
 * Please reference the Supported Mediation Partner page at http://bit.ly/2mqsuFH for the
 * latest version and ad format certifications.
 */
@interface MPMillennialInterstitialCustomEvent : MPInterstitialCustomEvent <MMInterstitialDelegate>

@property (nonatomic, readonly) MMInterstitialAd *interstitial;

@end
