#import "MPMillennialInterstitialCustomEvent.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPMillennialInterstitialCustomEvent (spec)

@property (nonatomic, strong) MMInterstitialAd *interstitial;

@end

SPEC_BEGIN(MPMillennialInterstitialCustomEventSpec)

describe(@"MPMillennialInterstitialCustomEvent", ^{
    __block id<CedarDouble, MPInterstitialCustomEventDelegate> delegate;
    __block MPMillennialInterstitialCustomEvent *event;
    __block MMInterstitialAd *interstitial;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPInterstitialCustomEventDelegate));
        event = [[MPMillennialInterstitialCustomEvent alloc] init];
        event.delegate = delegate;
    });

    it(@"should disable automatic metrics tracking", ^{
        event.enableAutomaticImpressionAndClickTracking should equal(NO);
    });

    context(@"when asked to fetch a configuration with an adunitid", ^{
        beforeEach(^{
            [event requestInterstitialWithCustomEventInfo:@{@"adUnitID": @"mmmmmmm"}];
            interstitial = event.interstitial;
        });

        it(@"should set the interstitial's ad unit ID and mediator", ^{
            interstitial.placementId should equal(@"mmmmmmm");
            [[MMSDK sharedInstance] appSettings].mediator should equal(@"MPMillennialInterstitialCustomEvent");
        });
    });

    context(@"when asked to fetch a configuration without an adunitid", ^{
        beforeEach(^{
            [event requestInterstitialWithCustomEventInfo:@{}];
            interstitial = event.interstitial;
        });

        it(@"should tell its delegate that it failed", ^{
            delegate should have_received(@selector(interstitialCustomEvent:didFailToLoadAdWithError:)).with(event).and_with(nil);
        });
    });

    context(@"when the interstitial load succeeds", ^{
        it(@"should notify the delegate", ^{
            [event interstitialAdLoadDidSucceed:interstitial];
            delegate should have_received(@selector(interstitialCustomEvent:didLoadAd:));
        });
    });

    context(@"when the interstitial load fails", ^{
        it(@"should notify the delegate", ^{
            [event interstitialAd:interstitial loadDidFailWithError:[NSError errorWithDomain:@"specs" code:1 userInfo:nil]];
            delegate should have_received(@selector(interstitialCustomEvent:didFailToLoadAdWithError:));
        });
    });

    context(@"when the interstitial load fails because an interstitial has already been loaded", ^{
        it(@"should notify the delegate of a load success", ^{
            [event interstitialAd:interstitial loadDidFailWithError:[NSError errorWithDomain:@"specs" code:MMSDKErrorInterstitialAdAlreadyLoaded userInfo:nil]];
            delegate should have_received(@selector(interstitialCustomEvent:didLoadAd:));
        });
    });

    context(@"when the interstitial successfully displays", ^{
        it(@"should notify the delegate and track an impression", ^{
            [event interstitialAdDidDisplay:interstitial];
            delegate should have_received(@selector(interstitialCustomEventDidAppear:));
            delegate should have_received(@selector(trackImpression));
        });
    });

    context(@"when the interstitial fails to display", ^{
        it(@"should notify the delegate", ^{
            [event interstitialAd:interstitial showDidFailWithError:[NSError errorWithDomain:@"specs" code:1 userInfo:nil]];
            delegate should have_received(@selector(interstitialCustomEventDidExpire:));
        });
    });
});

SPEC_END
