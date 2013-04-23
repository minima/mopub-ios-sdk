//
//  FakeIMAdView.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "IMAdView.h"

@interface FakeIMAdView : IMAdView

@property (nonatomic, assign) IMAdRequest *loadedRequest;

- (void)simulateLoadingAd;
- (void)simulateFailingToLoad;
- (void)simulateUserTap;
- (void)simulateUserEndingInteraction;
- (void)simulateUserLeavingApplication;

@end
