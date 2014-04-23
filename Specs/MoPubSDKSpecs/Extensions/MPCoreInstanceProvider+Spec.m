//
//  MPCoreInstanceProvider+Spec.m
//  MoPubSDK
//
//  Created by Evan Davis on 3/14/14.
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "MPCoreInstanceProvider+Spec.h"

@implementation MPCoreInstanceProvider (Spec)

+ (MPCoreInstanceProvider *)sharedProvider
{
    return fakeCoreProvider;
}


@end
