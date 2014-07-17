#import "InMobiNativeCustomEvent.h"
#import "NSOperationQueue+MPSpecs.h"
#import "MPNativeAd+Internal.h"
#import "MPNativeAd+Specs.h"
#import "IMNative+Specs.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(InMobiNativeCustomEventSpec)

describe(@"InMobiNativeCustomEvent", ^{
    NSDictionary *validInfo = @{@"app_id" : @"b15abe4c93a84f59a65faceca30c9591"};
    __block id<CedarDouble, MPNativeCustomEventDelegate> delegate;
    __block InMobiNativeCustomEvent *customEvent;

    [InMobi initialize:@"b15abe4c93a84f59a65faceca30c9591"];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPNativeCustomEventDelegate));
        customEvent = [[[InMobiNativeCustomEvent alloc] init] autorelease];
        customEvent.delegate = delegate;

        [NSOperationQueue mp_resetAddOperationWithBlockCount];
        [MPNativeAd mp_clearTrackMetricURLCallsCount];

    });

    context(@"when requesting an ad with valid info", ^{
        it(@"should download the main image and icon image", ^{
            [NSOperationQueue mp_addOperationWithBlockCount] should equal(0);
            [customEvent requestAdWithCustomEventInfo:validInfo];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
            [NSOperationQueue mp_addOperationWithBlockCount] should equal(3);
        });

        it(@"should call the success callback", ^{
            [customEvent requestAdWithCustomEventInfo:validInfo];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
            delegate should have_received("nativeCustomEvent:didLoadAd:");
        });
    });

    context(@"when requesting an ad with invalid info", ^{
        it(@"should call the failure callback", ^{
            [customEvent requestAdWithCustomEventInfo:nil];
            delegate should have_received("nativeCustomEvent:didFailToLoadAdWithError:");
        });
    });
});

SPEC_END
