#import "MPHTMLBannerCustomEvent.h"
#import "MPBannerCustomEventDelegate.h"
#import "MPAdConfigurationFactory.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPHTMLBannerCustomEventSpec)

describe(@"MPHTMLBannerCustomEvent", ^{
    __block MPHTMLBannerCustomEvent *event;
    __block id<CedarDouble, MPPrivateBannerCustomEventDelegate> delegate;
    __block MPAdWebViewAgent<CedarDouble> *bannerAgent;
    __block MPAdConfiguration *configuration;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPPrivateBannerCustomEventDelegate));
        bannerAgent = nice_fake_for([MPAdWebViewAgent class]);
        fakeProvider.fakeMPAdWebViewAgent = bannerAgent;

        configuration = [MPAdConfigurationFactory defaultBannerConfiguration];
        delegate stub_method("configuration").and_return(configuration);

        event = [[[MPHTMLBannerCustomEvent alloc] init] autorelease];
        event.delegate = delegate;

        [event requestAdWithSize:CGSizeZero customEventInfo:nil];
    });

    it(@"should disable automatic metrics tracking", ^{
        event.enableAutomaticImpressionAndClickTracking should equal(NO);
    });

    it(@"should properly set up the banner agent", ^{
        bannerAgent should have_received(@selector(loadConfiguration:)).with(configuration);
    });

    describe(@"forwarding the view controller along", ^{
        it(@"should", ^{
            UIViewController *controller = [[[UIViewController alloc] init] autorelease];
            delegate stub_method("viewControllerForPresentingModalView").and_return(controller);
            event.viewControllerForPresentingModalView should equal(controller);
        });
    });
});

SPEC_END
