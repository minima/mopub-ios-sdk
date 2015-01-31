//
//  VungleInterstitialCustomEvent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPInterstitialCustomEvent.h"
#endif

/*
 * Certified with version 3.0.8 of the Vungle SDK.
 *
 * The Vungle SDK does not provide an ad clicked callback. As a result, this custom event will not invoke delegate methods
 * interstitialCustomEventDidReceiveTapEvent: and interstitialCustomEventWillLeaveApplication:
 */

@interface VungleInterstitialCustomEvent : MPInterstitialCustomEvent

/**
 * Registers a Vungle app ID to be used when initializing the Vungle SDK.
 *
 * At initialization, the Vungle SDK requires you to provide your Vungle app ID. When
 * integrating Vungle using a MoPub custom event, this ID is typically configured via your
 * Vungle network settings on the MoPub website. However, if you wish, you may use this method to
 * manually provide the custom event with your app ID.
 *
 * IMPORTANT: If you choose to use this method, be sure to call it before making any ad requests,
 * and avoid calling it more than once. Otherwise, the Vungle SDK may be initialized improperly.
 */
+ (void)setAppId:(NSString *)appId;

@end
