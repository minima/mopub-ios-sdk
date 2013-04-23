//
//  MPAdInfo.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    MPAdInfoBanner,
    MPAdInfoInterstitial
} MPAdInfoType;

@interface MPAdInfo : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, assign) MPAdInfoType type;

+ (NSArray *)bannerAds;
+ (NSArray *)interstitialAds;
+ (MPAdInfo *)infoWithTitle:(NSString *)title ID:(NSString *)ID type:(MPAdInfoType)type;

@end
