//
//  FakeAdInterstitialAd.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FakeADInterstitialAd : NSObject <FakeInterstitialAd>

@property (nonatomic, weak) id <ADInterstitialAdDelegate> delegate;
@property (nonatomic, assign, readwrite, getter=isLoaded) BOOL loaded;
@property (nonatomic, strong) UIViewController *presentingViewController;
@property (nonatomic, strong) UIView *presentingView;

- (ADInterstitialAd *)masquerade;

- (void)simulateFailingToLoad;
- (void)simulateLoadingAd;
- (void)simulateUserDismissingAd;
- (void)simulateUnloadingAd;
- (void)simulateUserInteraction;
- (BOOL)presentInView:(UIView *)containerView;

@end
