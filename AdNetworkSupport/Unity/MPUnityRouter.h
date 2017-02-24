//
//  MPUnityRouter.h
//  MoPubSDK
//
//  Copyright (c) 2016 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UnityAds/UnityAds.h>
#import <UnityAds/UnityAdsExtended.h>

@protocol MPUnityRouterDelegate;
@class UnityAdsInstanceMediationSettings;

@interface MPUnityRouter : NSObject <UnityAdsExtendedDelegate>

@property (nonatomic, weak) id<MPUnityRouterDelegate> delegate;

+ (MPUnityRouter *)sharedRouter;

- (void)requestVideoAdWithGameId:(NSString *)gameId placementId:(NSString *)placementId delegate:(id<MPUnityRouterDelegate>)delegate;
- (BOOL)isAdAvailableForPlacementId:(NSString *)placementId;
- (void)presentVideoAdFromViewController:(UIViewController *)viewController customerId:(NSString *)customerId placementId:(NSString *)placementId settings:(UnityAdsInstanceMediationSettings *)settings delegate:(id<MPUnityRouterDelegate>)delegate;
- (void)clearDelegate:(id<MPUnityRouterDelegate>)delegate;

@end

@protocol MPUnityRouterDelegate <NSObject>

- (void)unityAdsReady:(NSString *)placementId;
- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message;
- (void)unityAdsDidStart:(NSString *)placementId;
- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state;
- (void)unityAdsDidClick:(NSString *)placementId;

- (void)unityAdsDidFailWithError:(NSError *)error;

@end
