//
//  MPRewardedVideo+Testing.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPRewardedVideo.h"
#import "MPAdConfiguration.h"

@interface MPRewardedVideo (Testing)
+ (void)setDidSendServerToServerCallbackUrl:(void(^)(NSURL * url))callback;
+ (void(^)(NSURL * url))didSendServerToServerCallbackUrl;

+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID withTestConfiguration:(MPAdConfiguration *)config;

@end
