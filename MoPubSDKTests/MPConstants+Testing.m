//
//  MPConstants+Testing.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPConstants+Testing.h"

static NSTimeInterval const kAdsExpirationTimeIntervalForTesting = 1; // 1 second

@implementation MPConstants (Testing)

+ (NSTimeInterval)adsExpirationInterval {
    return kAdsExpirationTimeIntervalForTesting;
}

@end
