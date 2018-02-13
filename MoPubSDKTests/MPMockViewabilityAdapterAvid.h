//
//  MPMockViewabilityAdapterAvid.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPViewabilityAdapter.h"

/**
 * This mock is named `MPViewabilityAdapterAvid` instead of `MPMockViewabilityAdapterAvid`
 * because `MPViewabilityTracker` is looking for that class name.
 */
@interface MPViewabilityAdapterAvid : NSObject <MPViewabilityAdapter>
@property (nonatomic, readonly) BOOL isTracking;

- (instancetype)initWithAdView:(UIView *)webView isVideo:(BOOL)isVideo startTrackingImmediately:(BOOL)startTracking;
- (void)startTracking;
- (void)stopTracking;
- (void)registerFriendlyObstructionView:(UIView *)view;

@end
