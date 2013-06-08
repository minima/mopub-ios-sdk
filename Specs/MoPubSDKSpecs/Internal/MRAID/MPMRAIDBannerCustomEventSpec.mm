#import "MPMRAIDBannerCustomEvent.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPMRAIDBannerCustomEventSpec)

describe(@"MPMRAIDBannerCustomEvent", ^{
    __block MPMRAIDBannerCustomEvent *event;

    beforeEach(^{
        event = [[[MPMRAIDBannerCustomEvent alloc] init] autorelease];
    });

    it(@"should allow automatic metrics tracking", ^{
        event.enableAutomaticImpressionAndClickTracking should equal(YES);
    });

    xit(@"should be tested someday", ^{
        // once we have the MRAdView fake
        // similar to MPHTMLBannerCustomEventSpec
    });
});

SPEC_END
