//
//  MPMockRewardedVideoCustomEvent.h
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPRewardedVideoCustomEvent.h"

@interface MPMockRewardedVideoCustomEvent : MPRewardedVideoCustomEvent

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup;

@end
