//
//  MPVungleRouter.m
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import "MPVungleRouter.h"
#import "MPInstanceProvider+Vungle.h"
#import "MPLogging.h"
#import "VungleInstanceMediationSettings.h"

static NSString *gAppId = nil;
NSString *const kMPVungleRewardedAdCompletedView = @"completedView";

@implementation MPVungleRouter

+ (void)setAppId:(NSString *)appId
{
    gAppId = [appId copy];
}

+ (MPVungleRouter *)sharedRouter
{
    return [[MPInstanceProvider sharedProvider] sharedMPVungleRouter];
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info andDelegate:(id<MPVungleRouterDelegate>)delegate
{
    self.delegate = delegate;

    static dispatch_once_t vungleInitToken;
    dispatch_once(&vungleInitToken, ^{
        NSString *appId = [info objectForKey:@"appId"];
        if ([appId length] == 0) {
            appId = gAppId;
        }

        [[VungleSDK sharedSDK] startWithAppId:appId];
        [[VungleSDK sharedSDK] setDelegate:self];
    });

    // Need to check immediately as an ad may be cached.
    if ([[VungleSDK sharedSDK] isCachedAdAvailable]) {
        [self.delegate vungleAdDidLoad];
    }

    // MoPub timeout will handle the case for an ad failing to load.
}

- (BOOL)isAdAvailable
{
    return [[VungleSDK sharedSDK] isCachedAdAvailable];
}

- (void)presentInterstitialAdFromViewController:(UIViewController *)viewController
{
    [[VungleSDK sharedSDK] playAd:viewController];
}

- (void)presentRewardedVideoAdFromViewController:(UIViewController *)viewController withSettings:(VungleInstanceMediationSettings *)settings
{
    NSDictionary *options;
    if (settings && [settings.userIdentifier length]) {
        options = @{VunglePlayAdOptionKeyIncentivized : @(YES), VunglePlayAdOptionKeyUser : settings.userIdentifier};
    } else {
        options = @{VunglePlayAdOptionKeyIncentivized : @(YES)};
    }
    [[VungleSDK sharedSDK] playAd:viewController withOptions:options];
}

- (void)clearDelegate:(id<MPVungleRouterDelegate>)delegate
{
    if(self.delegate == delegate)
    {
        [self setDelegate:nil];
    }
}

#pragma mark - VungleSDKDelegate

- (void)vungleSDKhasCachedAdAvailable
{
    [self.delegate vungleAdDidLoad];
}

- (void)vungleSDKwillShowAd
{
    [self.delegate vungleAdWillAppear];
}

- (void)vungleSDKwillCloseAdWithViewInfo:(NSDictionary *)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet
{
    if ([[viewInfo objectForKey:kMPVungleRewardedAdCompletedView] boolValue] && [self.delegate respondsToSelector:@selector(vungleAdShouldRewardUser)]) {
        [self.delegate vungleAdShouldRewardUser];
    }

    if (!willPresentProductSheet) {
        [self.delegate vungleAdWillDisappear];
    }
}

- (void)vungleSDKwillCloseProductSheet:(id)productSheet
{
    [self.delegate vungleAdWillDisappear];
}

@end
