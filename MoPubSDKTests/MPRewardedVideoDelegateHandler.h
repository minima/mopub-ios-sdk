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
@property (nonatomic, copy) void(^didLoadAd)();
@property (nonatomic, copy) void(^didFailToLoadAd)();
@property (nonatomic, copy) void(^didExpireAd)();
@property (nonatomic, copy) void(^didFailToPlayAd)();
@property (nonatomic, copy) void(^willAppear)();
@property (nonatomic, copy) void(^didAppear)();
@property (nonatomic, copy) void(^willDisappear)();
@property (nonatomic, copy) void(^didDisappear)();
@property (nonatomic, copy) void(^didReceiveTap)();
@property (nonatomic, copy) void(^willLeaveApp)();
@property (nonatomic, copy) void(^shouldRewardUser)(MPRewardedVideoReward *);

/**
 * Clears all of the handler blocks.
 */
- (void)resetHandlers;
@end
