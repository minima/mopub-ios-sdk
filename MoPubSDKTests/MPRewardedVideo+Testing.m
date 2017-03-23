//
//  MPRewardedVideo+Testing.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <objc/runtime.h>
#import "MPRewardedVideo+Testing.h"
#import "MPRewardedVideoAdManager.h"
#import "MPRewardedVideoAdManager+Testing.h"

@interface MPRewardedVideo() <MPRewardedVideoAdManagerDelegate>
// Redeclared methods and properties from MPRewardedVideo so we can access them in this category.
+ (MPRewardedVideo *)sharedInstance;
@property (nonatomic, strong) NSMutableDictionary *rewardedVideoAdManagers;
- (void)startRewardedVideoConnectionWithUrl:(NSURL *)url;
@end

@implementation MPRewardedVideo (Testing)

#pragma mark - Properties
static void(^sDidSendServerToServerCallbackUrl)(NSURL * url) = nil;

+ (void)setDidSendServerToServerCallbackUrl:(void(^)(NSURL * url))callback
{
    sDidSendServerToServerCallbackUrl = [callback copy];
}

+ (void(^)(NSURL * url))didSendServerToServerCallbackUrl
{
    return sDidSendServerToServerCallbackUrl;
}

#pragma mark - Life Cycle

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector = @selector(startRewardedVideoConnectionWithUrl:);
        SEL swizzledSelector = @selector(testing_startRewardedVideoConnectionWithUrl:);

        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        // ...
        // Method originalMethod = class_getClassMethod(class, originalSelector);
        // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);

        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

#pragma mark - Public Methods

+ (void)loadRewardedVideoAdWithAdUnitID:(NSString *)adUnitID withTestConfiguration:(MPAdConfiguration *)config {
    MPRewardedVideo *sharedInstance = [MPRewardedVideo sharedInstance];
    MPRewardedVideoAdManager * adManager = sharedInstance.rewardedVideoAdManagers[adUnitID];

    if (!adManager) {
        adManager = [[MPRewardedVideoAdManager alloc] initWithAdUnitID:adUnitID delegate:sharedInstance];
        sharedInstance.rewardedVideoAdManagers[adUnitID] = adManager;
    }

    [adManager loadWithConfiguration:config];
}

#pragma mark - Swizzles

- (void)testing_startRewardedVideoConnectionWithUrl:(NSURL *)url {
    if (sDidSendServerToServerCallbackUrl != nil) {
        sDidSendServerToServerCallbackUrl(url);
    }
}

@end
