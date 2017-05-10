//
//  MPRewardedVideoAdapter+Testing.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPRewardedVideoAdapter.h"

@interface MPRewardedVideoAdapter (Testing)

- (void)rewardedVideoDidLoadAdForCustomEvent:(MPRewardedVideoCustomEvent *)customEvent;

@property (nonatomic, assign) BOOL hasTrackedImpression;
@property (nonatomic, assign) BOOL hasExpired;

@end
