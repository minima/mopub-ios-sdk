//
//  MPMockRewardedVideoAdapter.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPMockRewardedVideoAdapter.h"
#import "MPAdConfiguration.h"

@interface MPMockRewardedVideoAdapter()
@property (nonatomic, strong) MPAdConfiguration * configuration;
@end

@implementation MPMockRewardedVideoAdapter
@dynamic configuration;

- (instancetype)initWithDelegate:(id<MPRewardedVideoAdapterDelegate>)delegate configuration:(MPAdConfiguration *)config {
    if (self = [super initWithDelegate:delegate]) {
        self.configuration = config;
    }

    return self;
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController {
    [self.delegate rewardedVideoWillAppearForAdapter:self];
    [self.delegate rewardedVideoDidAppearForAdapter:self];

    if (self.configuration.rewardedVideoCompletionUrl == nil) {
        [self.delegate rewardedVideoShouldRewardUserForAdapter:self reward:self.configuration.selectedReward];
    }
    else {
        [self rewardedVideoShouldRewardUserForCustomEvent:nil reward:self.configuration.selectedReward];
    }

    [self.delegate rewardedVideoWillDisappearForAdapter:self];
    [self.delegate rewardedVideoDidDisappearForAdapter:self];
}

@end
