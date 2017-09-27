//
//  MPRewardedVideoAdManager+Testing.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPRewardedVideoAdManager.h"
#import "MPAdConfiguration.h"
#import "MPRewardedVideoAdapter.h"
#import "MPAdServerCommunicator.h"
#import "MPRewardedVideoAdapter+Testing.h"

@interface MPRewardedVideoAdManager (Testing) <MPAdServerCommunicatorDelegate>
@property (nonatomic, strong) MPAdServerCommunicator * communicator;
@property (nonatomic, strong) MPRewardedVideoAdapter * adapter;

/**
 * Pretends to load the class with a rewarded ad and sets the configuration.
 * @param config Testing configuration to set.
 */
- (void)loadWithConfiguration:(MPAdConfiguration *)config;

@end
