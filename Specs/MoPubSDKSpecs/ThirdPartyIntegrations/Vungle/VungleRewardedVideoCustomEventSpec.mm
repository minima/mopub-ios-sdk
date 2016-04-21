#import "VungleRewardedVideoCustomEvent.h"
#import "MPRewardedVideo.h"
#import "VungleSDK+Specs.h"
#import "MPVungleRouter.h"
#import "VungleInstanceMediationSettings.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(VungleRewardedVideoCustomEventSpec)

describe(@"VungleRewardedVideoCustomEvent", ^{
    __block VungleRewardedVideoCustomEvent *model;
    __block id<CedarDouble, MPRewardedVideoCustomEventDelegate> delegate;
    __block VungleSDK *sharedSDK;
    __block MPVungleRouter *router;

    beforeEach(^{
        model = [[VungleRewardedVideoCustomEvent alloc] init];
        delegate = nice_fake_for(@protocol(MPRewardedVideoCustomEventDelegate));
        model.delegate = delegate;

        sharedSDK = [VungleSDK sharedSDK];
        router = [MPVungleRouter sharedRouter];
    });

    context(@"when requesting a Vungle video ad", ^{
        beforeEach(^{
            [model requestRewardedVideoWithCustomEventInfo:[NSDictionary dictionaryWithObject:@"CUSTOM_APP_ID" forKey:@"appId"]];
        });

        it(@"should set itself as the Vungle router's delegate", ^{
            [router delegate] should equal(model);
        });

        it(@"should use the app id from the info dictionary", ^{
            [VungleSDK mp_getAppId] should equal(@"CUSTOM_APP_ID");
        });

        context(@"when Vungle sends us vungleSDKAdPlayableChanged with an ad being playable", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                [router vungleSDKAdPlayableChanged:YES];
            });

            it(@"should notify the delegate ad did load", ^{
                delegate should have_received(@selector(rewardedVideoDidLoadAdForCustomEvent:));
            });
        });

        context(@"when Vungle sends us isAdPlayable with an ad not being playable", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                [router vungleSDKAdPlayableChanged:NO];
            });

            it(@"should not tell the delegate an ad loaded", ^{
                delegate should_not have_received(@selector(rewardedVideoDidLoadAdForCustomEvent:));
            });
        });

        context(@"when Vungle sends us vungleSDKwillCloseAdWithViewInfo", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
            });

            describe(@"with presenting a product sheet", ^{
                beforeEach(^{
                    [router vungleSDKwillCloseAdWithViewInfo:nil willPresentProductSheet:YES];
                });

                it(@"should not send disappear messages to the delegate", ^{
                    delegate should_not have_received(@selector(rewardedVideoWillAppearForCustomEvent:));
                    delegate should_not have_received(@selector(rewardedVideoDidAppearForCustomEvent:));
                });

                it(@"should not trigger a click event", ^{
                    delegate should_not have_received(@selector(rewardedVideoDidReceiveTapEventForCustomEvent:));
                });
            });

            describe(@"with not presenting a product sheet", ^{
                beforeEach(^{
                    [router vungleSDKwillCloseAdWithViewInfo:nil willPresentProductSheet:NO];
                });

                it(@"should send disappear messages to the delegate", ^{
                    delegate should have_received(@selector(rewardedVideoWillDisappearForCustomEvent:));
                    delegate should have_received(@selector(rewardedVideoDidDisappearForCustomEvent:));
                });

                it(@"should not trigger a click event", ^{
                    delegate should_not have_received(@selector(rewardedVideoDidReceiveTapEventForCustomEvent:));
                });
            });

            describe(@"signifying that the user did click to download app", ^{
                beforeEach(^{
                    NSDictionary *info = @{@"didDownload" : @(YES)};
                    [router vungleSDKwillCloseAdWithViewInfo:info willPresentProductSheet:NO];
                });

                it(@"should not send disappear messages to the delegate", ^{
                    delegate should_not have_received(@selector(rewardedVideoWillAppearForCustomEvent:));
                    delegate should_not have_received(@selector(rewardedVideoDidAppearForCustomEvent:));
                });

                it(@"should trigger a click event", ^{
                    delegate should have_received(@selector(rewardedVideoDidReceiveTapEventForCustomEvent:));
                });
            });

            describe(@"signifying that the user did not click to download app", ^{
                beforeEach(^{
                    NSDictionary *info = @{@"didDownload" : @(NO)};
                    [router vungleSDKwillCloseAdWithViewInfo:info willPresentProductSheet:NO];
                });

                it(@"should not send disappear messages to the delegate", ^{
                    delegate should_not have_received(@selector(rewardedVideoWillAppearForCustomEvent:));
                    delegate should_not have_received(@selector(rewardedVideoDidAppearForCustomEvent:));
                });

                it(@"should not trigger a click event", ^{
                    delegate should_not have_received(@selector(rewardedVideoDidReceiveTapEventForCustomEvent:));
                });
            });
        });

        context(@"when Vungle sends us vungleSDKwillCloseAdWithViewInfo:willPresentProductSheet:", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
            });

            it(@"should send disappear and reward messages to the delegate", ^{
                [router vungleSDKwillCloseAdWithViewInfo:@{@"completedView":@(YES)} willPresentProductSheet:NO];
                delegate should have_received(@selector(rewardedVideoShouldRewardUserForCustomEvent:reward:));
                delegate should have_received(@selector(rewardedVideoWillDisappearForCustomEvent:));
                delegate should have_received(@selector(rewardedVideoDidDisappearForCustomEvent:));
            });
        });

        context(@"when Vungle sends us vungleSDKwillCloseProductSheet", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
            });

            it(@"should send disappear messages to the delegate", ^{
                [router vungleSDKwillCloseProductSheet:nil];
                delegate should have_received(@selector(rewardedVideoWillDisappearForCustomEvent:));
                delegate should have_received(@selector(rewardedVideoDidDisappearForCustomEvent:));
            });
        });

        context(@"when Vungle sends us vungleSDKwillShowAd", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
            });

            it(@"should send appear messages to the delegate", ^{
                [router vungleSDKwillShowAd];
                delegate should have_received(@selector(rewardedVideoWillAppearForCustomEvent:));
                delegate should have_received(@selector(rewardedVideoDidAppearForCustomEvent:));
            });
        });
    });

    context(@"when playing a Vungle video ad", ^{
        __block UIViewController *controller;

        beforeEach(^{
            spy_on(router);
            router stub_method(@selector(isAdAvailable)).and_return(YES);
            controller = [[UIViewController alloc] init];
        });

        context(@"when using instance mediation settings", ^{
            it(@"should pass the userIdentifier to the Vungle SDK", ^{
                VungleInstanceMediationSettings *settings = [[VungleInstanceMediationSettings alloc] init];
                settings.userIdentifier = @"user_identifier";
                delegate stub_method(@selector(instanceMediationSettingsForClass:)).and_return(settings);

                [model presentRewardedVideoFromViewController:controller];
                [[VungleSDK mp_getPlayOptionsDictionary] objectForKey:VunglePlayAdOptionKeyUser] should equal(@"user_identifier");
            });
        });

        context(@"when not using instance mediation settings", ^{
            it(@"should not pass a userIdentifier to the Vungle SDK", ^{
                [model presentRewardedVideoFromViewController:controller];
                [[VungleSDK mp_getPlayOptionsDictionary] objectForKey:VunglePlayAdOptionKeyUser] should be_nil;
            });
        });
    });

    context(@"when there are multiple requests to load a Vungle video ad", ^{
        __block VungleRewardedVideoCustomEvent *secondModel;
        __block id<CedarDouble, MPRewardedVideoCustomEventDelegate> secondDelegate;

        beforeEach(^{
            secondModel = [[VungleRewardedVideoCustomEvent alloc] init];
            secondDelegate = nice_fake_for(@protocol(MPRewardedVideoCustomEventDelegate));
            secondModel.delegate = secondDelegate;

            [model requestRewardedVideoWithCustomEventInfo:nil];
            [secondModel requestRewardedVideoWithCustomEventInfo:nil];
        });

        it(@"secondModel should be the Vungle router's delegate", ^{
            [router delegate] should equal(secondModel);

            [router vungleSDKAdPlayableChanged:YES];
            secondDelegate should have_received(@selector(rewardedVideoDidLoadAdForCustomEvent:));
            delegate should_not have_received(@selector(rewardedVideoDidLoadAdForCustomEvent:));
        });

        context(@"when the current Vungle delegate is invalidated", ^{
            beforeEach(^{
                [secondModel performSelector:@selector(handleCustomEventInvalidated) withObject:nil];
            });

            it(@"should nil out the Vungle router's delegate", ^{
                [router delegate] should be_nil;
            });

            context(@"when another custom event requests a Vungle ad", ^{
                beforeEach(^{
                    [model requestRewardedVideoWithCustomEventInfo:nil];
                });

                it(@"should be the Vungle router's delegate", ^{
                    [router delegate] should equal(model);
                });
            });
        });
    });
});

SPEC_END
