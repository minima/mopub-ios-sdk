//
//  MPStubCustomEvent.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPStubCustomEvent.h"

static BOOL sIsInitialized = false;

@implementation MPStubCustomEvent

#pragma mark - Testing

+ (BOOL)isInitialized {
    return sIsInitialized;
}

+ (void)resetInitialization {
    sIsInitialized = false;
}

#pragma mark - MPRewardedVideoCustomEvent Overrides

- (void)initializeSdkWithParameters:(NSDictionary *)parameters {
    sIsInitialized = true;
}

@end
