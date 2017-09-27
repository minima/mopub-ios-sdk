//
//  MPStaticNativeAdImpressionTimer+Testing.h
//  MoPubSDKTests
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPStaticNativeAdImpressionTimer.h"

@interface MPStaticNativeAdImpressionTimer (Testing)

@property (nonatomic, assign) CGFloat requiredViewVisibilityPercentage;
@property (nonatomic, readonly) NSTimeInterval requiredSecondsForImpression;

@end
