//
//  MPPrivateRewardedVideoCustomEventDelegateHandler.h
//  MoPubSDK
//
//  Copyright © 2016 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPPrivateRewardedVideoCustomEventDelegate.h"

@interface MPPrivateRewardedVideoCustomEventDelegateHandler : NSObject <MPPrivateRewardedVideoCustomEventDelegate>
@property (nonatomic, copy) void(^didLoadAd)();
@property (nonatomic, copy) void(^didFailToLoadAd)();
@property (nonatomic, copy) void(^didExpireAd)();
@property (nonatomic, copy) void(^willAppear)();
@property (nonatomic, copy) void(^didAppear)();
@property (nonatomic, copy) void(^willDisappear)();
@property (nonatomic, copy) void(^didDisappear)();
@property (nonatomic, copy) void(^willLeaveApp)();
@property (nonatomic, copy) void(^didReceiveTap)();
@property (nonatomic, copy) void(^shouldRewardUser)();

- (instancetype)initWithAdUnitId:(NSString *)adUnitId configuration:(MPAdConfiguration *)config;
@end

