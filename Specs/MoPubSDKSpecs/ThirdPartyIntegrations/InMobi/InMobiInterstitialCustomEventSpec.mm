#import "InMobiInterstitialCustomEvent.h"
#import "FakeIMAdInterstitial.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(InMobiInterstitialCustomEventSpec)

describe(@"InMobiInterstitialCustomEvent", ^{
    __block InMobiInterstitialCustomEvent *event;
    __block FakeIMAdInterstitial *interstitial;
    __block IMAdRequest<CedarDouble> *request;

    beforeEach(^{
        event = [[[InMobiInterstitialCustomEvent alloc] init] autorelease];
        interstitial = [[[FakeIMAdInterstitial alloc] init] autorelease];
        fakeProvider.fakeIMAdInterstitial = interstitial;
        request = nice_fake_for([IMAdRequest class]);
        fakeProvider.fakeIMAdInterstitialRequest = request;
    });

    context(@"when requesting an interstitial", ^{
        beforeEach(^{
            [event requestInterstitialWithCustomEventInfo:nil];
        });

        it(@"should load with a proper request object", ^{
            interstitial.request should equal(request);
            request should have_received(@selector(setParamsDictionary:)).with(@{@"tp": @"c_mopub"});
        });
    });
});

SPEC_END
