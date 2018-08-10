//
//  MPBannerAdapterDelegateHandler.m
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import "MPBannerAdapterDelegateHandler.h"

@implementation MPBannerAdapterDelegateHandler

- (void)adapter:(MPBaseBannerAdapter *)adapter didFailToLoadAdWithError:(NSError *)error {
    if (self.didFailToLoadAd != nil) { self.didFailToLoadAd(error); }
}

- (void)adapter:(MPBaseBannerAdapter *)adapter didFinishLoadingAd:(UIView *)ad {
    if (self.didLoadAd != nil) { self.didLoadAd(); }
}

- (void)userActionWillBeginForAdapter:(MPBaseBannerAdapter *)adapter {
    if (self.willBeginUserAction != nil) { self.willBeginUserAction(); }
}

- (void)userActionDidFinishForAdapter:(MPBaseBannerAdapter *)adapter {
    if (self.didFinishUserAction != nil) { self.didFinishUserAction(); }
}

- (void)userWillLeaveApplicationFromAdapter:(MPBaseBannerAdapter *)adapter {
    if (self.willLeaveApplication != nil) { self.willLeaveApplication(); }
}

- (void)adapter:(MPBaseBannerAdapter *)adapter didTrackImpressionForAd:(UIView *)ad {
    if (self.didTrackImpression != nil) { self.didTrackImpression(); }
}

@end
