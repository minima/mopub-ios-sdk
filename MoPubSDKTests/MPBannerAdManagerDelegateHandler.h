//
//  MPBannerAdManagerDelegateHandler.h
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPBannerAdManager.h"
#import "MPBannerAdManagerDelegate.h"

typedef void(^MPBannerAdManagerDelegateHandlerBlock)(void);

@interface MPBannerAdManagerDelegateHandler : NSObject <MPBannerAdManagerDelegate>

@property (nonatomic, copy) NSString * adUnitId;
@property (nonatomic, assign) MPNativeAdOrientation allowedNativeAdsOrientation;
@property (nonatomic, strong) MPAdView * banner;
@property (nonatomic, weak) id<MPAdViewDelegate> bannerDelegate;
@property (nonatomic, assign) CGSize containerSize;
@property (nonatomic, copy) NSString * keywords;
@property (nonatomic, copy) NSString * userDataKeywords;
@property (nonatomic, strong) CLLocation * location;
@property (nonatomic, strong) UIViewController * viewControllerForPresentingModalView;

@property (nonatomic, copy) MPBannerAdManagerDelegateHandlerBlock didLoadAd;
@property (nonatomic, copy) MPBannerAdManagerDelegateHandlerBlock didFailToLoadAd;
@property (nonatomic, copy) MPBannerAdManagerDelegateHandlerBlock willBeginUserAction;
@property (nonatomic, copy) MPBannerAdManagerDelegateHandlerBlock didEndUserAction;
@property (nonatomic, copy) MPBannerAdManagerDelegateHandlerBlock willLeaveApplication;

@end
