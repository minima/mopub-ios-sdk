#import "MPVungleRouter.h"
#import "VungleInterstitialCustomEvent.h"
#import "VungleRewardedVideoCustomEvent.h"
#import "VungleSDK+Specs.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPVungleRouter (Specs)

@property (nonatomic, assign) BOOL isAdPlaying;

@end

SPEC_BEGIN(MPVungleRouterSpec)

describe(@"MPVungleRouter", ^{
    __block MPVungleRouter *router;
    __block VungleSDK *SDK;
    __block id<CedarDouble, MPVungleRouterDelegate> delegate;
    __block UIViewController *controller;

    beforeEach(^{
        router = [MPVungleRouter sharedRouter];
        SDK = [VungleSDK sharedSDK];
        spy_on(SDK);
        delegate = nice_fake_for(@protocol(MPVungleRouterDelegate));
        controller = [[UIViewController alloc] init];
    });

    afterEach(^{
        router.isAdPlaying = NO;
    });

    context(@"when an ad is not already playing", ^{
        beforeEach(^{
            SDK stub_method(@selector(isAdPlayable)).and_return(YES);
        });

        it(@"should attempt to play an interstitial ad", ^{
            [router presentInterstitialAdFromViewController:controller withDelegate:delegate];
            SDK should have_received(@selector(playAd:error:));
        });

        it(@"should attempt to play a rewarded video ad", ^{
            [router presentRewardedVideoAdFromViewController:controller customerId:@"customerId" settings:nil delegate:delegate];
            SDK should have_received(@selector(playAd:withOptions:error:));
        });

        context(@"when the SDK fails to play the ad", ^{
            beforeEach(^{
                SDK stub_method(@selector(playAd:error:)).and_do_block(^BOOL(UIViewController *controller, NSError **error){
                    if (error) {
                        *error = [NSError errorWithDomain:@"domain" code:1 userInfo:@{}];
                    }
                    return NO;
                });

                SDK stub_method(@selector(playAd:withOptions:error:)).and_do_block(^BOOL(UIViewController *controller, id options, NSError **error){
                    if (error) {
                        *error = [NSError errorWithDomain:@"domain" code:1 userInfo:@{}];
                    }
                    return NO;
                });
            });

            it(@"should notify its delegate that it couldn't play the interstitial ad", ^{
                [router presentInterstitialAdFromViewController:controller withDelegate:delegate];
                delegate should have_received(@selector(vungleAdDidFailToPlay:));
            });

            it(@"should notify its delegate that it couldn't play the rewarded video ad", ^{
                [router presentRewardedVideoAdFromViewController:controller customerId:@"customerId"  settings:nil delegate:delegate];
                delegate should have_received(@selector(vungleAdDidFailToPlay:));
            });
        });
    });

    context(@"when an interstitial ad is already playing", ^{
        beforeEach(^{
            SDK stub_method(@selector(isAdPlayable)).and_return(YES);
            [router presentInterstitialAdFromViewController:controller withDelegate:delegate];
        });

        it(@"should fail to play an interstitial", ^{
            [router presentInterstitialAdFromViewController:controller withDelegate:delegate];
            delegate should have_received(@selector(vungleAdDidFailToPlay:));
        });

        it(@"should fail to play a rewarded video", ^{
            [router presentRewardedVideoAdFromViewController:controller customerId:@"customerId"  settings:nil delegate:delegate];
            delegate should have_received(@selector(vungleAdDidFailToPlay:));
        });
    });

    context(@"when a rewarded video ad is already playing", ^{
        beforeEach(^{
            SDK stub_method(@selector(isAdPlayable)).and_return(YES);
            [router presentRewardedVideoAdFromViewController:controller customerId:@"customerId"  settings:nil delegate:delegate];
        });

        it(@"should fail to play an interstitial", ^{
            [router presentInterstitialAdFromViewController:controller withDelegate:delegate];
            delegate should have_received(@selector(vungleAdDidFailToPlay:));
        });

        it(@"should fail to play a rewarded video", ^{
            [router presentRewardedVideoAdFromViewController:controller customerId:@"customerId" settings:nil delegate:delegate];
            delegate should have_received(@selector(vungleAdDidFailToPlay:));
        });
    });

    context(@"when an interstitial ad closes", ^{
        beforeEach(^{
            SDK stub_method(@selector(isAdPlayable)).and_return(YES);
            [router presentInterstitialAdFromViewController:controller withDelegate:delegate];
            router.isAdPlaying should be_truthy;
        });

        it(@"should set isAdPlaying to NO and notify delegate when no product sheet is shown", ^{
            [router vungleSDKwillCloseAdWithViewInfo:nil willPresentProductSheet:NO];
            router.isAdPlaying should be_falsy;
            delegate should have_received(@selector(vungleAdWillDisappear));
        });

        it(@"should set isAdPlaying to NO and notify delegate after the product sheet is dismissed", ^{
            [router vungleSDKwillCloseAdWithViewInfo:nil willPresentProductSheet:YES];
            router.isAdPlaying should be_truthy;
            [router vungleSDKwillCloseProductSheet:nil];
            router.isAdPlaying should be_falsy;
            delegate should have_received(@selector(vungleAdWillDisappear));
        });
    });

    context(@"when a rewarded video ad ad closes", ^{
        beforeEach(^{
            SDK stub_method(@selector(isAdPlayable)).and_return(YES);
            [router presentRewardedVideoAdFromViewController:controller customerId:@"customerId" settings:nil delegate:delegate];
            router.isAdPlaying should be_truthy;
        });

        it(@"should set isAdPlaying to NO and notify delegate when no product sheet is shown", ^{
            [router vungleSDKwillCloseAdWithViewInfo:nil willPresentProductSheet:NO];
            router.isAdPlaying should be_falsy;
            delegate should have_received(@selector(vungleAdWillDisappear));
        });

        it(@"should set isAdPlaying to NO and notify delegate after the product sheet is dismissed", ^{
            [router vungleSDKwillCloseAdWithViewInfo:nil willPresentProductSheet:YES];
            router.isAdPlaying should be_truthy;
            [router vungleSDKwillCloseProductSheet:nil];
            router.isAdPlaying should be_falsy;
            delegate should have_received(@selector(vungleAdWillDisappear));
        });
    });

    context(@"when an ad is not available", ^{
        beforeEach(^{
            SDK stub_method(@selector(isAdPlayable)).and_return(NO);
            router.isAdPlaying = NO;
        });

        it(@"should not play an interstitial ad", ^{
            [router presentInterstitialAdFromViewController:controller withDelegate:delegate];
            delegate should have_received(@selector(vungleAdDidFailToPlay:));
        });

        it(@"should not play a rewarded video ad", ^{
            [router presentRewardedVideoAdFromViewController:controller customerId:@"customerId" settings:nil delegate:delegate];
            delegate should have_received(@selector(vungleAdDidFailToPlay:));
        });
    });
});

SPEC_END
