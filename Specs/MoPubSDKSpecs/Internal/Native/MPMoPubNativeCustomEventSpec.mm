#import "MPNativeAdConstants.h"
#import "MPInstanceProvider.h"
#import "NSOperationQueue+MPSpecs.h"
#import "MPMoPubNativeCustomEvent.h"

#define kImpressionTrackerURLsKey   @"imptracker"
#define kDefaultActionURLKey        @"clk"
#define kClickTrackerURLKey         @"clktracker"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPMoPubNativeCustomEventSpec)

describe(@"MPMoPubNativeCustomEvent", ^{
    NSDictionary *validInfo = @{kAdTitleKey : @"WUT",
                                kAdTextKey : @"WUT DaWG",
                                kAdIconImageKey : @"https://pbs.twimg.com/profile_images/431949550836662272/A6Ck-0Gx_normal.png",
                                kAdMainImageKey : @"https://pbs.twimg.com/profile_images/431949550836662272/A6Ck-0Gx_normal.png",
                                kAdCTATextKey : @"DO IT",
                                kImpressionTrackerURLsKey: @[@"http://www.mopub.com/tearinupmyheartwhenimwithyou", @"http://www.mopub.com/pop"],
                                kClickTrackerURLKey : @"http://www.mopub.com/byebyebye",
                                kDefaultActionURLKey : @"http://www.mopub.com/iwantyouback"
                                };
    __block id<CedarDouble, MPNativeCustomEventDelegate> delegate;
    __block MPMoPubNativeCustomEvent *customEvent;

    beforeEach(^{
        [NSOperationQueue mp_resetAddOperationWithBlockCount];
        delegate = nice_fake_for(@protocol(MPNativeCustomEventDelegate));
        customEvent = (MPMoPubNativeCustomEvent *)[[MPInstanceProvider sharedProvider] buildNativeCustomEventFromCustomClass:[MPMoPubNativeCustomEvent class] delegate:delegate];
    });

    afterEach(^{
    });

    context(@"when requesting an ad with valid info", ^{
        it(@"should attempt to download the images in the info", ^{
            [NSOperationQueue mp_addOperationWithBlockCount] should equal(0);
            [customEvent requestAdWithCustomEventInfo:validInfo];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
            [NSOperationQueue mp_addOperationWithBlockCount] should equal(3);
        });

        it(@"should call completion block with success", ^{
            // Since the NSOperationQueue doesn't actually make the request, we can rely on waiting a couple seconds to make sure we got the callback.
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
