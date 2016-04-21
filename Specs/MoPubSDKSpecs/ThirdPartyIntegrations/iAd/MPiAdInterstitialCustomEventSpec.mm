#import "MPiAdInterstitialCustomEvent.h"
#import "FakeAdInterstitialAd.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPiAdInterstitialCustomEvent (Specs) <ADInterstitialAdDelegate>

@property (nonatomic, strong) UIViewController *iAdInterstitialViewController;

@end

SPEC_BEGIN(MPiAdInterstitialCustomEventSpec)

describe(@"MPiAdInterstitialCustomEvent", ^{
    __block id<CedarDouble, MPInterstitialCustomEventDelegate> delegate;
    __block MPiAdInterstitialCustomEvent *event;
    __block FakeADInterstitialAd *interstitial;

    beforeEach(^{
        interstitial = [[FakeADInterstitialAd alloc] init];
        fakeProvider.fakeADInterstitialAd = interstitial.masquerade;

        delegate = nice_fake_for(@protocol(MPInterstitialCustomEventDelegate));
        event = [[MPiAdInterstitialCustomEvent alloc] init];
        event.delegate = delegate;
        [event requestInterstitialWithCustomEventInfo:nil];
    });

    it(@"should allow automatic metrics tracking", ^{
        event.enableAutomaticImpressionAndClickTracking should equal(YES);
    });

    context(@"when asked to show the interstitial", ^{
        __block UIViewController *presentingController;

        beforeEach(^{
            presentingController = [[UIViewController alloc] init];
        });

        context(@"when the interstitial is loaded", ^{
            beforeEach(^{
                interstitial.loaded = YES;
                [event showInterstitialFromRootViewController:presentingController];
            });

            it(@"should tell its delegate that an interstitial will appear", ^{
                delegate should have_received(@selector(interstitialCustomEventWillAppear:)).with(event);
            });

            it(@"should show the iAd interstitial in the custom event's own view controller's view", ^{
                interstitial.presentingView should equal(event.iAdInterstitialViewController.view);
            });

            it(@"should tell its delegate that an interstitial did appear", ^{
                delegate should have_received(@selector(interstitialCustomEventDidAppear:)).with(event);
            });
        });

        context(@"when the interstitial is not loaded", ^{
            beforeEach(^{
                interstitial.loaded = NO;
                [event showInterstitialFromRootViewController:presentingController];
            });

            it(@"should tell its delegate that the show attempt failed", ^{
                delegate should have_received(@selector(interstitialCustomEvent:didFailToLoadAdWithError:));
            });

            it(@"should not tell the interstitial view controller to show the interstitial", ^{
                interstitial.presentingView should be_nil;
            });
        });
    });

    context(@"when the interstitial is tapped", ^{
        it(@"should allow the interstitial to proceed with its action", ^{
            [event interstitialAdActionShouldBegin:interstitial.masquerade willLeaveApplication:YES] should equal(YES);
        });
    });

    context(@"when the interstitial has been dismissed using the close button without other user interaction", ^{
        beforeEach(^{
            interstitial.loaded = YES;
            [event showInterstitialFromRootViewController:[[UIViewController alloc] init]];
            [event.iAdInterstitialViewController performSelector:@selector(closeButtonPressed) withObject:nil];
        });

        it(@"should tell its delegate", ^{
            delegate should have_received(@selector(interstitialCustomEventWillDisappear:)).with(event);
            delegate should have_received(@selector(interstitialCustomEventDidDisappear:)).with(event);
        });
    });

    context(@"when the interstitial has been dismissed after user interaction", ^{
        beforeEach(^{
            interstitial.loaded = YES;
            [event showInterstitialFromRootViewController:[[UIViewController alloc] init]];
            [interstitial simulateUserDismissingAd];
        });

        it(@"should tell its delegate", ^{
            delegate should have_received(@selector(interstitialCustomEventWillDisappear:)).with(event);
            delegate should have_received(@selector(interstitialCustomEventDidDisappear:)).with(event);
        });
    });

    context(@"when the interstitial is dismissed and unloaded", ^{
        beforeEach(^{
            interstitial.loaded = YES;
            [event showInterstitialFromRootViewController:[[UIViewController alloc] init]];
            [interstitial simulateUserDismissingAd];
            [delegate reset_sent_messages];
            [interstitial simulateUnloadingAd];
        });

        it(@"should not send duplicate disappear events", ^{
            delegate should_not have_received(@selector(interstitialCustomEventWillDisappear:)).with(event);
            delegate should_not have_received(@selector(interstitialCustomEventDidDisappear:)).with(event);
        });
    });

    context(@"when the interstitial has unloaded", ^{
        context(@"after having been displayed", ^{
            beforeEach(^{
                interstitial.loaded = YES;
                [event showInterstitialFromRootViewController:[[UIViewController alloc] init]];
                [interstitial simulateUnloadingAd];
            });

            it(@"should tell its delegate", ^{
                delegate should have_received(@selector(interstitialCustomEventWillDisappear:)).with(event);
                delegate should have_received(@selector(interstitialCustomEventDidDisappear:)).with(event);
                delegate should have_received(@selector(interstitialCustomEventDidExpire:)).with(event);
            });
        });

        context(@"without being displayed", ^{
            beforeEach(^{
                [interstitial simulateUnloadingAd];
            });

            it(@"should only tell its delegate that the interstitial expired", ^{
                delegate should_not have_received(@selector(interstitialCustomEventWillDisappear:)).with(event);
                delegate should_not have_received(@selector(interstitialCustomEventDidDisappear:)).with(event);
                delegate should have_received(@selector(interstitialCustomEventDidExpire:)).with(event);
            });
        });
    });
});

SPEC_END
