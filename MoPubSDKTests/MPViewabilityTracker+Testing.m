//
//  MPViewabilityTracker+Testing.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPViewabilityTracker+Testing.h"

@interface MPViewabilityTracker ()

@property (nonatomic, assign, readonly) MPViewabilityOption trackersInProgress;

@end

@implementation MPViewabilityTracker (Testing)

- (BOOL)isTracking {
    return self.trackersInProgress != MPViewabilityOptionNone;
}

@end
