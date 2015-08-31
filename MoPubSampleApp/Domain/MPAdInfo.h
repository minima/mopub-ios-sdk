//
//  MPAdInfo.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MPAdInfoType) {
    MPAdInfoBanner,
    MPAdInfoInterstitial,
    MPAdInfoRewardedVideo,
    MPAdInfoMRectBanner,
    MPAdInfoLeaderboardBanner,
    MPAdInfoNative,
    MPAdInfoNativeInTableView,
    MPAdInfoNativeTableViewPlacer,
    MPAdInfoNativePageViewControllerPlacer,
    MPAdInfoNativeInCollectionView
};

@interface MPAdInfo : NSObject <NSCoding>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, assign) MPAdInfoType type;
@property (nonatomic, copy) NSString *keywords;

+ (NSArray *)bannerAds;
+ (NSArray *)interstitialAds;
+ (NSArray *)rewardedVideoAds;
+ (NSArray *)nativeAds;
+ (MPAdInfo *)infoWithTitle:(NSString *)title ID:(NSString *)ID type:(MPAdInfoType)type;
+ (NSArray *)supportedAdTypeNames;

@end
