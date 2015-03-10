//
//  MPVungleRouter.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VungleSDK/VungleSDK.h>

@protocol MPVungleRouterDelegate;
@class VungleInstanceMediationSettings;

@interface MPVungleRouter : NSObject <VungleSDKDelegate>

@property (nonatomic, weak) id<MPVungleRouterDelegate> delegate;

+ (void)setAppId:(NSString *)appId;

+ (MPVungleRouter *)sharedRouter;

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info andDelegate:(id<MPVungleRouterDelegate>)delegate;
- (BOOL)isAdAvailable;
- (void)presentInterstitialAdFromViewController:(UIViewController *)viewController;
- (void)presentRewardedVideoAdFromViewController:(UIViewController *)viewController withSettings:(VungleInstanceMediationSettings *)settings;
- (void)clearDelegate:(id<MPVungleRouterDelegate>)delegate;
@end

@protocol MPVungleRouterDelegate <NSObject>

- (void)vungleAdDidLoad;
- (void)vungleAdWillAppear;
- (void)vungleAdWillDisappear;

@optional

- (void)vungleAdShouldRewardUser;

@end
