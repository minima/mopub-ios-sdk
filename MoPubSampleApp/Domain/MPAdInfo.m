//
//  MPAdInfo.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdInfo.h"

#import <Foundation/Foundation.h>

NSString * const kAdInfoIdKey = @"adUnitId";
NSString * const kAdInfoFormatKey = @"format";
NSString * const kAdInfoKeywordsKey = @"keywords";
NSString * const kAdInfoNameKey = @"name";

@implementation MPAdInfo

+ (NSDictionary *)supportedAddedAdTypes
{
    static NSDictionary *adTypes = nil;

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        adTypes = @{@"Banner":@(MPAdInfoBanner), @"Interstitial":@(MPAdInfoInterstitial), @"MRect":@(MPAdInfoMRectBanner), @"Leaderboard":@(MPAdInfoLeaderboardBanner), @"Native":@(MPAdInfoNative), @"Rewarded Video":@(MPAdInfoRewardedVideo), @"Rewarded":@(MPAdInfoRewardedVideo), @"NativeTablePlacer":@(MPAdInfoNativeTableViewPlacer), @"NativeCollectionPlacer":@(MPAdInfoNativeInCollectionView)};
    });

    return adTypes;
}

+ (NSArray *)bannerAds
{
    NSMutableArray *ads = [NSMutableArray array];

    [ads addObjectsFromArray:@[
                               [MPAdInfo infoWithTitle:@"HTML Banner Ad" ID:@"0ac59b0996d947309c33f59d6676399f" type:MPAdInfoBanner],
                               [MPAdInfo infoWithTitle:@"MRAID Banner Ad" ID:@"23b49916add211e281c11231392559e4" type:MPAdInfoBanner],
                               [MPAdInfo infoWithTitle:@"HTML MRECT Banner Ad" ID:@"2aae44d2ab91424d9850870af33e5af7" type:MPAdInfoMRectBanner],
                               ]];

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [ads addObject:[MPAdInfo infoWithTitle:@"HTML Leaderboard Banner Ad" ID:@"d456ea115eec497ab33e02531a5efcbc" type:MPAdInfoLeaderboardBanner]];
    }

    // 3rd Party Networks
#if CUSTOM_EVENTS_ENABLED
    [ads addObject:[MPAdInfo infoWithTitle:@"Facebook" ID:@"446dfa864dcb4469965267694a940f3d" type:MPAdInfoBanner]];
    [ads addObject:[MPAdInfo infoWithTitle:@"Flurry" ID:@"b827dff81325466e95cc6d475f207fb3" type:MPAdInfoBanner]];
    [ads addObject:[MPAdInfo infoWithTitle:@"Google AdMob" ID:@"c9c2ea9a8e1249b68496978b072d2fd2" type:MPAdInfoBanner]];
    [ads addObject:[MPAdInfo infoWithTitle:@"Millennial" ID:@"b506db1f3e054c78bff513f188727748" type:MPAdInfoBanner]];
#endif

    return ads;
}

+ (NSArray *)interstitialAds
{
    return @[
             [MPAdInfo infoWithTitle:@"HTML Interstitial Ad" ID:@"4f117153f5c24fa6a3a92b818a5eb630" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"MRAID Interstitial Ad" ID:@"3aba0056add211e281c11231392559e4" type:MPAdInfoInterstitial],

    // 3rd Party Networks
    #if CUSTOM_EVENTS_ENABLED
             [MPAdInfo infoWithTitle:@"Chartboost" ID:@"a425ff78959911e295fa123138070049" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Facebook" ID:@"cec4c5ea0ff140d3a15264da23449f97" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Flurry" ID:@"5124d5ff5e3944d2ab8ad496b87a0978" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Flurry RTB" ID:@"49960150e2874e9294105af00a77b85c" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Google AdMob" ID:@"744e217f8adc4dec89c87481c9c4006a" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Millennial" ID:@"93c3fc00fbb54825b6a33b20927315f7" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Tapjoy" ID:@"8f66c17adff74e189555247bc1bd26c4" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Vungle" ID:@"20e01fce81f611e295fa123138070049" type:MPAdInfoInterstitial],
    #endif
             ];
}

+ (NSArray *)rewardedVideoAds
{
    return @[
             [MPAdInfo infoWithTitle:@"Rewarded Video Ad" ID:@"8f000bd5e00246de9c789eed39ff6096" type:MPAdInfoRewardedVideo],
             [MPAdInfo infoWithTitle:@"Rewarded Rich Media Ad" ID:@"98c29e015e7346bd9c380b1467b33850" type:MPAdInfoRewardedVideo],
    // 3rd Party Networks
    #if CUSTOM_EVENTS_ENABLED
             [MPAdInfo infoWithTitle:@"AdColony" ID:@"52aa460767374250a5aa5174c2345be3" type:MPAdInfoRewardedVideo],
             [MPAdInfo infoWithTitle:@"AdMob" ID:@"0ceacb73895748ceadf0048a1f989855" type:MPAdInfoRewardedVideo],
             [MPAdInfo infoWithTitle:@"Chartboost" ID:@"8be0bb08fb4f4e90a86416c29c235d4a" type:MPAdInfoRewardedVideo],
             [MPAdInfo infoWithTitle:@"Facebook" ID:@"5a138cf1a03643ca851647d2b2e20d0d" type:MPAdInfoRewardedVideo],
             [MPAdInfo infoWithTitle:@"Millennial" ID:@"1908cd1ff0934f69bac04c316accc854" type:MPAdInfoRewardedVideo],
             [MPAdInfo infoWithTitle:@"Tapjoy" ID:@"58e30d62673e4c85b2098887a4218816" type:MPAdInfoRewardedVideo],
             [MPAdInfo infoWithTitle:@"Unity Ads" ID:@"676a0fa97aca48cbbe489de5b2fa4cd1" type:MPAdInfoRewardedVideo],
             [MPAdInfo infoWithTitle:@"Vungle" ID:@"48274e80f11b496bb3532c4f59f28d12" type:MPAdInfoRewardedVideo],
    #endif
             ];
}

+ (NSArray *)nativeAds
{
    return @[
             [MPAdInfo infoWithTitle:@"Native Ad" ID:@"76a3fefaced247959582d2d2df6f4757" type:MPAdInfoNative],
             [MPAdInfo infoWithTitle:@"Native Video Ad" ID:@"b2b67c2a8c0944eda272ed8e4ddf7ed4" type:MPAdInfoNative],
             [MPAdInfo infoWithTitle:@"Native Ad (CollectionView Placer)" ID:@"76a3fefaced247959582d2d2df6f4757" type:MPAdInfoNativeInCollectionView],
             [MPAdInfo infoWithTitle:@"Native Ad (TableView Placer)" ID:@"76a3fefaced247959582d2d2df6f4757" type:MPAdInfoNativeTableViewPlacer],
             [MPAdInfo infoWithTitle:@"Native Video Ad (TableView Placer)" ID:@"b2b67c2a8c0944eda272ed8e4ddf7ed4" type:MPAdInfoNativeTableViewPlacer],

    // 3rd Party Networks
    #if CUSTOM_EVENTS_ENABLED
             [MPAdInfo infoWithTitle:@"Facebook" ID:@"1ceee46ba9744155aed48ee6277ecbd6" type:MPAdInfoNative],
             [MPAdInfo infoWithTitle:@"Flurry Native Ad" ID:@"1023187dc1984ec28948b49220e1e3d4" type:MPAdInfoNative],
             [MPAdInfo infoWithTitle:@"Flurry Native Ad (TableView Placer)" ID:@"1023187dc1984ec28948b49220e1e3d4" type:MPAdInfoNativeTableViewPlacer],
             [MPAdInfo infoWithTitle:@"Google AdMob" ID:@"e1598f16673a409e95c66e79ba592aeb" type:MPAdInfoNative],
             [MPAdInfo infoWithTitle:@"Millennial" ID:@"69b2d2cfda6a4d07aefa1847066c89ab" type:MPAdInfoNative],
    #endif
             ];
}

+ (MPAdInfo *)infoWithTitle:(NSString *)title ID:(NSString *)ID type:(MPAdInfoType)type {
    MPAdInfo *info = [[MPAdInfo alloc] init];
    info.title = title;
    info.ID = ID;
    info.type = type;
    return info;
}

+ (MPAdInfo *)infoWithDictionary:(NSDictionary *)dict
{
    // Extract the required fields from the dictionary. If either of the required fields
    // is invalid, object creation will not be performed.
    NSString * adUnitId = [[dict objectForKey:kAdInfoIdKey] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * formatString = [[dict objectForKey:kAdInfoFormatKey] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * keywords = [[dict objectForKey:kAdInfoKeywordsKey] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * name = [[dict objectForKey:kAdInfoNameKey] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    if (adUnitId.length == 0 || formatString.length == 0 || (formatString != nil && [[self supportedAddedAdTypes] objectForKey:formatString] == nil)) {
        return nil;
    }

    MPAdInfoType format = (MPAdInfoType)[[[self supportedAddedAdTypes] objectForKey:formatString] integerValue];
    NSString * title = (name != nil ? name : adUnitId);
    MPAdInfo * info = [MPAdInfo infoWithTitle:title ID:adUnitId type:format];
    info.keywords = keywords;

    return info;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self != nil)
    {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.ID = [aDecoder decodeObjectForKey:@"ID"];
        self.type = [aDecoder decodeIntegerForKey:@"type"];
        self.keywords = [aDecoder decodeObjectForKey:@"keywords"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeInteger:self.type forKey:@"type"];
    [aCoder encodeObject:((self.keywords != nil) ? self.keywords : @"") forKey:@"keywords"];
}

@end
