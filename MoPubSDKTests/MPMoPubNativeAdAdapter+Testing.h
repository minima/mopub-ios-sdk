//
//  MPMoPubNativeAdAdapter+Testing.h
//  MoPubSDKTests
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPMoPubNativeAdAdapter.h"
#import "MPStaticNativeAdImpressionTimer.h"

@interface MPMoPubNativeAdAdapter (Testing)

@property (nonatomic) MPStaticNativeAdImpressionTimer *impressionTimer;

@end
