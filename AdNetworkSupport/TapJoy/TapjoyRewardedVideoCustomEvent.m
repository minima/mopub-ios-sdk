
#import "TapjoyRewardedVideoCustomEvent.h"

#import <Tapjoy/TJPlacement.h>
#import <Tapjoy/Tapjoy.h>
#import "MPRewardedVideoError.h"
#import "MPLogging.h"
#import "MPRewardedVideoReward.h"
#import "TapjoyGlobalMediationSettings.h"
#import "MoPub.h"

@interface TapjoyRewardedVideoCustomEvent () <TJPlacementDelegate, TJCVideoAdDelegate>
@property (nonatomic, strong) TJPlacement *placement;
@end

@implementation TapjoyRewardedVideoCustomEvent

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Requesting Tapjoy rewarded video");
    //Instantiate Mediation Settings
    TapjoyGlobalMediationSettings *medSettings = [[MoPub sharedInstance] globalMediationSettingsForClass:[TapjoyGlobalMediationSettings class]];

    if (![Tapjoy isConnected]) {
        [Tapjoy connect:medSettings.sdkKey
                options:medSettings.connectFlags];
    }
    // Grab placement name defined in MoPub dashboard as custom event data
    NSString *name = info[@"name"];

    if(name) {
        _placement = [TJPlacement placementWithName:name mediationAgent:@"mopub" mediationId:nil delegate:self];
        _placement.adapterVersion = @"3.0";

        [_placement requestContent];
    }
    else {
        MPLogInfo(@"Invalid Tapjoy placement name specified");
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorInvalidCustomEvent userInfo:nil];
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
    }
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController
{
    if ([self hasAdAvailable]) {
        MPLogInfo(@"Tapjoy rewarded video will be shown");
        [_placement showContentWithViewController:nil];
    }
    else {
        MPLogInfo(@"Failed to show Tapjoy rewarded video");
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    }

}

- (BOOL)hasAdAvailable
{
    return _placement.isContentAvailable;
}

- (void)handleCustomEventInvalidated
{
    _placement.delegate = nil;
}

- (void)handleAdPlayedForCustomEventNetwork
{
    // If we no longer have an ad available, report back up to the application that this ad expired.
    // We receive this message only when this ad has reported an ad has loaded and another ad unit
    // has played a video for the same ad network.
    if (![self hasAdAvailable]) {
        [self.delegate rewardedVideoDidExpireForCustomEvent:self];
    }
}

- (void)dealloc
{
    _placement.delegate = nil;
}

#pragma mark - TJPlacementDelegate methods
- (void)requestDidSucceed:(TJPlacement *)placement {
    if (!placement.isContentAvailable) {
        MPLogInfo(@"No Tapjoy rewarded videos available");
        NSError *error = [NSError errorWithDomain:MoPubRewardedVideoAdsSDKDomain code:MPRewardedVideoAdErrorNoAdsAvailable userInfo:nil];
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
    }
}

- (void)contentIsReady:(TJPlacement *)placement {
    MPLogInfo(@"Tapjoy rewarded video content is ready");
    [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
}
- (void)requestDidFail:(TJPlacement *)placement error:(NSError *)error {
    MPLogInfo(@"Tapjoy rewarded video request failed");
    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
}

- (void)contentDidAppear:(TJPlacement *)placement {
    MPLogInfo(@"Tapjoy rewarded video content did appear");
    [Tapjoy setVideoAdDelegate:self];
    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
}

- (void)contentDidDisappear:(TJPlacement *)placement {
    MPLogInfo(@"Tapjoy rewarded video content did disappear");
    [Tapjoy setVideoAdDelegate:nil];
    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
}

#pragma mark Tapjoy Video

- (void)videoAdCompleted {
    MPLogInfo(@"Tapjoy rewarded video completed");
    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:[[MPRewardedVideoReward alloc] initWithCurrencyAmount:@(kMPRewardedVideoRewardCurrencyAmountUnspecified)]];
}



@end
