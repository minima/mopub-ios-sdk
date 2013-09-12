//
//  FakeIMAdView.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "IMBanner.h"
#import "IMBannerDelegate.h"
#import "IMInMobiNetworkExtras.h"

@interface FakeIMAdView : IMBanner

@property (nonatomic, retain) IMInMobiNetworkExtras *fakeNetworkExtras;

- (void)simulateLoadingAd;
- (void)simulateFailingToLoad;
- (void)simulateUserTap;
- (void)simulateUserEndingInteraction;
- (void)simulateUserLeavingApplication;

@end
