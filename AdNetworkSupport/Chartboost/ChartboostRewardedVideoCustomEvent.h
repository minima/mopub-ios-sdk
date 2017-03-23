//
//  ChartboostRewardedVideoCustomEvent.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#else
    #import "MPRewardedVideoCustomEvent.h"
#endif

/*
 * Please reference the Supported Mediation Partner page at http://bit.ly/2mqsuFH for the
 * latest version and ad format certifications.
 */
@interface ChartboostRewardedVideoCustomEvent : MPRewardedVideoCustomEvent

/**
 * A string that corresponds to a Chartboost CBLocation used for differentiating ad requests.
 */
@property (nonatomic, copy) NSString *location;

@end
