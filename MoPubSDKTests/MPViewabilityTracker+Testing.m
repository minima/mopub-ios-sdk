//
//  MPViewabilityTracker+Testing.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPViewabilityTracker+Testing.h"
#import "MPViewabilityAdapter.h"

@interface MPViewabilityTracker ()
@property (nonatomic, strong) NSDictionary<NSNumber *, id<MPViewabilityAdapter>> * trackers;
@end

@implementation MPViewabilityTracker (Testing)

- (BOOL)isTracking {
    __block BOOL someTrackerIsRunning = NO;
    [self.trackers.allValues enumerateObjectsUsingBlock:^(id<MPViewabilityAdapter>  _Nonnull tracker, NSUInteger idx, BOOL * _Nonnull stop) {
        someTrackerIsRunning |= tracker.isTracking;
    }];

    return someTrackerIsRunning;
}

@end
