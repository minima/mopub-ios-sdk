#import "MRProperty.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MRPropertySpec)

describe(@"MRSupportsProperty", ^{
    __block MRSupportsProperty *supportsProperty;

    beforeEach(^{
        supportsProperty = [MRSupportsProperty propertyWithSupportedFeaturesDictionary:
                            @{@"sms": @YES,
                            @"tel": @YES,
                            @"calendar": @NO,
                            @"storePicture": @NO,
                            @"inlineVideo": @YES}];
    });

    it(@"should serialize properly", ^{
        [supportsProperty description] should equal(@"supports: {sms: true, tel: true, calendar: false, storePicture: false, inlineVideo: true}");
    });
});

SPEC_END
