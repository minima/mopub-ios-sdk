//
//  MPBannerAdManagerDelegateHandler.m
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import "MPBannerAdManagerDelegateHandler.h"

@implementation MPBannerAdManagerDelegateHandler

#pragma mark - MPBannerAdManagerDelegate

- (void)invalidateContentView {
    // Do nothing.
}

- (void)managerDidLoadAd:(UIView *)ad {
    if (self.didLoadAd != nil) { self.didLoadAd(); }
}

- (void)managerDidFailToLoadAd {
    if (self.didFailToLoadAd != nil) { self.didFailToLoadAd(); }
}

- (void)userActionWillBegin {
    if (self.willBeginUserAction != nil) { self.willBeginUserAction(); }
}

- (void)userActionDidFinish {
    if (self.didEndUserAction != nil) { self.didEndUserAction(); }
}

- (void)userWillLeaveApplication {
    if (self.willLeaveApplication != nil) { self.willLeaveApplication(); }
}

@end
