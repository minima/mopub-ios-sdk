//
//  MPRewardedVideoAdapterDelegateHandler.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPRewardedVideoAdapterDelegateHandler.h"

@implementation MPRewardedVideoAdapterDelegateHandler

- (id<MPMediationSettingsProtocol>)instanceMediationSettingsForClass:(Class)aClass {
    if (self.instanceMediationSettingsForClass)
        return self.instanceMediationSettingsForClass(aClass);
    else
        return Nil;
}

- (void)rewardedVideoDidLoadForAdapter:(MPRewardedVideoAdapter *)adapter { if (self.rewardedVideoDidLoad) self.rewardedVideoDidLoad(adapter); }
- (void)rewardedVideoDidFailToLoadForAdapter:(MPRewardedVideoAdapter *)adapter error:(NSError *)error { if (self.rewardedVideoDidFailToLoad) self.rewardedVideoDidFailToLoad(adapter, error); }
- (void)rewardedVideoDidExpireForAdapter:(MPRewardedVideoAdapter *)adapter { if (self.rewardedVideoDidExpire) self.rewardedVideoDidExpire(adapter); }
- (void)rewardedVideoDidFailToPlayForAdapter:(MPRewardedVideoAdapter *)adapter error:(NSError *)error { if (self.rewardedVideoDidFailToPlay) self.rewardedVideoDidFailToPlay(adapter, error); }
- (void)rewardedVideoWillAppearForAdapter:(MPRewardedVideoAdapter *)adapter { if (self.rewardedVideoWillAppear) self.rewardedVideoWillAppear(adapter); }
- (void)rewardedVideoDidAppearForAdapter:(MPRewardedVideoAdapter *)adapter { if (self.rewardedVideoDidAppear) self.rewardedVideoDidAppear(adapter); }
- (void)rewardedVideoWillDisappearForAdapter:(MPRewardedVideoAdapter *)adapter { if (self.rewardedVideoWillDisappear) self.rewardedVideoWillDisappear(adapter); }
- (void)rewardedVideoDidDisappearForAdapter:(MPRewardedVideoAdapter *)adapter { if (self.rewardedVideoDidDisappear) self.rewardedVideoDidDisappear(adapter); }
- (void)rewardedVideoDidReceiveTapEventForAdapter:(MPRewardedVideoAdapter *)adapter { if (self.rewardedVideoDidReceiveTapEvent) self.rewardedVideoDidReceiveTapEvent(adapter); }
- (void)rewardedVideoWillLeaveApplicationForAdapter:(MPRewardedVideoAdapter *)adapter { if (self.rewardedVideoWillLeaveApplication) self.rewardedVideoWillLeaveApplication(adapter); }
- (void)rewardedVideoShouldRewardUserForAdapter:(MPRewardedVideoAdapter *)adapter reward:(MPRewardedVideoReward *)reward { if (self.rewardedVideoShouldRewardUser) self.rewardedVideoShouldRewardUser(adapter, reward); }

@end
