//
//  MPMoPubNativeAdAdapter+Testing.h
//  MoPubSDKTests
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPMoPubNativeAdAdapter.h"
#import "MPAdDestinationDisplayAgent.h"
#import "MPAdImpressionTimer.h"

@interface MPMoPubNativeAdAdapter (Testing)

@property (nonatomic) MPAdImpressionTimer *impressionTimer;
@property (nonatomic, strong) MPAdDestinationDisplayAgent *destinationDisplayAgent;

// Expose private methods for testing
- (void)displayContentForDAAIconTap;

@end
