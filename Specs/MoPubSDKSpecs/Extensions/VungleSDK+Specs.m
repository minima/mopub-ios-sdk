//
//  VungleSDK+Specs.m
//  MoPubSDK
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "VungleSDK+Specs.h"

static NSString *gAppId;
static NSDictionary *gPlayOptions;

@implementation VungleSDK (Specs)

- (void)startWithAppId:(NSString *)appId
{
    gAppId = [appId copy];
}


- (void)playAd:(UIViewController *)viewController withOptions:(id)options
{
    gPlayOptions = options;
}

+ (NSString *)mp_getAppId
{
    return gAppId;
}

+ (NSDictionary *)mp_getPlayOptionsDictionary
{
    return gPlayOptions;
}

@end
