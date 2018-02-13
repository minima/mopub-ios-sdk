//
//  MPMockViewabilityAdapterAvid.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPMockViewabilityAdapterAvid.h"

@interface MPViewabilityAdapterAvid()
@property (nonatomic, readwrite) BOOL isTracking;
@end

@implementation MPViewabilityAdapterAvid

- (instancetype)initWithAdView:(UIView *)webView isVideo:(BOOL)isVideo startTrackingImmediately:(BOOL)startTracking {
    if (self = [super init]) {
        _isTracking = startTracking;
    }

    return self;
}

- (void)startTracking {
    self.isTracking = YES;
}

- (void)stopTracking {
    self.isTracking = NO;
}

- (void)registerFriendlyObstructionView:(UIView *)view {

}

@end
