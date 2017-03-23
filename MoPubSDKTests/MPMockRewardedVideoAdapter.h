//
//  MPMockRewardedVideoAdapter.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPRewardedVideoAdapter.h"
#import "MPAdConfiguration.h"

@interface MPMockRewardedVideoAdapter : MPRewardedVideoAdapter

- (instancetype)initWithDelegate:(id<MPRewardedVideoAdapterDelegate>)delegate configuration:(MPAdConfiguration *)config;

@end
