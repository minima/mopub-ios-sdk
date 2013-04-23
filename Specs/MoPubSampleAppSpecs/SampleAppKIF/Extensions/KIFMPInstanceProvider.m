//
//  KIFMPInstanceProvider.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFMPInstanceProvider.h"
#import "GSBannerAdView.h"
#import "GSFullscreenAd.h"
#import "GSAdDelegate.h"
#import "IMAdInterstitial.h"
#import "IMAdView.h"
#import "IMAdInterstitialDelegate.h"

static KIFMPInstanceProvider *sharedProvider = nil;

@interface MPInstanceProvider (ThirdPartyIntegrations)

- (GSFullscreenAd *)buildGSFullscreenAdWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID;
- (GSBannerAdView *)buildGreystripeBannerAdViewWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID size:(CGSize)size;
- (IMAdInterstitial *)buildIMAdInterstitialWithDelegate:(id<IMAdInterstitialDelegate>)delegate appId:(NSString *)appId;
- (IMAdView *)buildIMAdViewWithFrame:(CGRect)frame appId:(NSString *)appId adSize:(int)adSize;
- (IMAdRequest *)buildIMAdRequest;

@end

@implementation MPInstanceProvider (KIF)

+ (MPInstanceProvider *)sharedProvider
{
    if (!sharedProvider) {
        sharedProvider = [[KIFMPInstanceProvider alloc] init];
    }
    return sharedProvider;
}

@end

@implementation KIFMPInstanceProvider

- (GSFullscreenAd *)buildGSFullscreenAdWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID
{
    return [super buildGSFullscreenAdWithDelegate:delegate GUID:@"1d73efc1-c8c5-44e6-9b02-b6dd29374c1c"];
}

- (GSBannerAdView *)buildGreystripeBannerAdViewWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID size:(CGSize)size
{
    return [super buildGreystripeBannerAdViewWithDelegate:delegate GUID:@"1d73efc1-c8c5-44e6-9b02-b6dd29374c1c" size:size];
}

- (IMAdInterstitial *)buildIMAdInterstitialWithDelegate:(id<IMAdInterstitialDelegate>)delegate appId:(NSString *)appId
{
    return [super buildIMAdInterstitialWithDelegate:delegate appId:@"5d6694314fbe4ddb804eab8eb4ad6693"];
}

- (IMAdView *)buildIMAdViewWithFrame:(CGRect)frame appId:(NSString *)appId adSize:(int)adSize {
    return [super buildIMAdViewWithFrame:frame appId:@"5d6694314fbe4ddb804eab8eb4ad6693" adSize:adSize];
}

- (IMAdRequest *)buildIMAdRequest
{
    IMAdRequest *request = [super buildIMAdRequest];
    return request;
}

@end
