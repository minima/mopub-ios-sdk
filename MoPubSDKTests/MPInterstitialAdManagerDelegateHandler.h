//
//  MPInterstitialAdManagerDelegateHandler.h
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPInterstitialAdManager.h"
#import "MPInterstitialAdManagerDelegate.h"

typedef void(^MPInterstitialAdManagerDelegateHandlerBlock)(void);
typedef void(^MPInterstitialAdManagerDelegateHandlerErrorBlock)(NSError *);

@interface MPInterstitialAdManagerDelegateHandler : NSObject <MPInterstitialAdManagerDelegate>

@property (nonatomic, strong) MPInterstitialAdController * interstitialAdController;
@property (nonatomic, strong) CLLocation * location;
@property (nonatomic, weak) id interstitialDelegate;

@property (nonatomic, copy) MPInterstitialAdManagerDelegateHandlerBlock didLoadAd;
@property (nonatomic, copy) MPInterstitialAdManagerDelegateHandlerErrorBlock didFailToLoadAd;
@property (nonatomic, copy) MPInterstitialAdManagerDelegateHandlerBlock willPresent;
@property (nonatomic, copy) MPInterstitialAdManagerDelegateHandlerBlock didPresent;
@property (nonatomic, copy) MPInterstitialAdManagerDelegateHandlerBlock willDismiss;
@property (nonatomic, copy) MPInterstitialAdManagerDelegateHandlerBlock didDismiss;
@property (nonatomic, copy) MPInterstitialAdManagerDelegateHandlerBlock didExpire;
@property (nonatomic, copy) MPInterstitialAdManagerDelegateHandlerBlock didTap;

@end
