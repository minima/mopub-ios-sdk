//
//  MPRewardedVideoDelegateHandler.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPRewardedVideoAdManager.h"
#import "MPRewardedVideo.h"

/**
 * Delegate capturing object used to handle the following protocols:
 * - MPRewardedVideoAdManagerDelegate
 * - MPRewardedVideoDelegate
 */
@interface MPRewardedVideoDelegateHandler : NSObject <MPRewardedVideoAdManagerDelegate, MPRewardedVideoDelegate>
@property (nonatomic, copy) void(^didLoadAd)(void);
@property (nonatomic, copy) void(^didFailToLoadAd)(void);
@property (nonatomic, copy) void(^didExpireAd)(void);
@property (nonatomic, copy) void(^didFailToPlayAd)(void);
@property (nonatomic, copy) void(^willAppear)(void);
@property (nonatomic, copy) void(^didAppear)(void);
@property (nonatomic, copy) void(^willDisappear)(void);
@property (nonatomic, copy) void(^didDisappear)(void);
@property (nonatomic, copy) void(^didReceiveTap)(void);
@property (nonatomic, copy) void(^willLeaveApp)(void);
@property (nonatomic, copy) void(^shouldRewardUser)(MPRewardedVideoReward *);

/**
 * Clears all of the handler blocks.
 */
- (void)resetHandlers;
@end
