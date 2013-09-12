#import "InMobiInterstitialCustomEvent.h"
#import "FakeIMAdInterstitial.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(InMobiInterstitialCustomEventSpec)

describe(@"InMobiInterstitialCustomEvent", ^{
    __block InMobiInterstitialCustomEvent *event;
    __block FakeIMAdInterstitial *interstitial;

    beforeEach(^{
        [InMobi initialize:@"YOUR_INMOBI_APP_ID"];

        event = [[[InMobiInterstitialCustomEvent alloc] init] autorelease];
        interstitial = [[[FakeIMAdInterstitial alloc] init] autorelease];
        fakeProvider.fakeIMAdInterstitial = interstitial;
    });

    context(@"when requesting an interstitial", ^{
        beforeEach(^{
            [event requestInterstitialWithCustomEventInfo:nil];
        });

        it(@"should load with a proper params dictionary", ^{
            NSDictionary *params = interstitial.fakeNetworkExtras.additionaParameters;
            NSString *tpValue = [params objectForKey:@"tp"];
            tpValue should equal(@"c_mopub");
        });
    });
});

SPEC_END
