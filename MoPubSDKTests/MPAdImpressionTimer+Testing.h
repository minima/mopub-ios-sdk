//
//  MPAdImpressionTimer+Testing.h
//  MoPubSDKTests
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPAdImpressionTimer.h"

@interface MPAdImpressionTimer (Testing)

@property (nonatomic) CGFloat pixelsRequiredForViewVisibility;
@property (nonatomic) CGFloat percentageRequiredForViewVisibility;
@property (nonatomic) NSTimeInterval requiredSecondsForImpression;

@end
