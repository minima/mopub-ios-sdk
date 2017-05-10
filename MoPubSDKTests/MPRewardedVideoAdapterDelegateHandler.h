//
//  MPRewardedVideoAdapterDelegateHandler.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPRewardedVideoAdapter.h"

typedef void (^MPRewardedVideoAdapterDelegateHandlerBlock)(MPRewardedVideoAdapter *);
typedef void (^MPRewardedVideoAdapterDelegateHandlerErrorBlock)(MPRewardedVideoAdapter *, NSError *);
typedef void (^MPRewardedVideoAdapterDelegateHandlerRewardBlock)(MPRewardedVideoAdapter *, MPRewardedVideoReward *);
typedef id<MPMediationSettingsProtocol> (^MPRewardedVideoAdapterDelegateHandlerInstanceMediationSettingsBlock)(Class);

@interface MPRewardedVideoAdapterDelegateHandler : NSObject <MPRewardedVideoAdapterDelegate>

@property (nonatomic, copy) MPRewardedVideoAdapterDelegateHandlerInstanceMediationSettingsBlock instanceMediationSettingsForClass;
@property (nonatomic, copy) MPRewardedVideoAdapterDelegateHandlerBlock rewardedVideoDidLoad;
@property (nonatomic, copy) MPRewardedVideoAdapterDelegateHandlerErrorBlock rewardedVideoDidFailToLoad;
@property (nonatomic, copy) MPRewardedVideoAdapterDelegateHandlerBlock rewardedVideoDidExpire;
@property (nonatomic, copy) MPRewardedVideoAdapterDelegateHandlerErrorBlock rewardedVideoDidFailToPlay;
@property (nonatomic, copy) MPRewardedVideoAdapterDelegateHandlerBlock rewardedVideoWillAppear;
@property (nonatomic, copy) MPRewardedVideoAdapterDelegateHandlerBlock rewardedVideoDidAppear;
@property (nonatomic, copy) MPRewardedVideoAdapterDelegateHandlerBlock rewardedVideoWillDisappear;
@property (nonatomic, copy) MPRewardedVideoAdapterDelegateHandlerBlock rewardedVideoDidDisappear;
@property (nonatomic, copy) MPRewardedVideoAdapterDelegateHandlerBlock rewardedVideoDidReceiveTapEvent;
@property (nonatomic, copy) MPRewardedVideoAdapterDelegateHandlerBlock rewardedVideoWillLeaveApplication;
@property (nonatomic, copy) MPRewardedVideoAdapterDelegateHandlerRewardBlock rewardedVideoShouldRewardUser;

@property (nonatomic, copy) NSString *rewardedVideoAdUnitId;
@property (nonatomic, copy) NSString *rewardedVideoCustomerId;
@property (nonatomic, strong) MPAdConfiguration *configuration;

@end
