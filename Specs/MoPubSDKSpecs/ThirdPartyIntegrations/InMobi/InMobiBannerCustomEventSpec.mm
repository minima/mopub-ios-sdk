#import "InMobiBannerCustomEvent.h"
#import "FakeIMAdView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(InMobiBannerCustomEventSpec)

describe(@"InMobiBannerCustomEvent", ^{
    __block id<CedarDouble, MPBannerCustomEventDelegate> delegate;
    __block InMobiBannerCustomEvent *event;
    __block CLLocation *location;
    __block FakeIMAdView *banner;
    __block IMAdRequest<CedarDouble> *request;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPBannerCustomEventDelegate));

        request = nice_fake_for([IMAdRequest class]);
        fakeProvider.fakeIMAdBannerRequest = request;

        event = [[[InMobiBannerCustomEvent alloc] init] autorelease];
        event.delegate = delegate;

        banner = [[[FakeIMAdView alloc] initWithFrame:CGRectZero] autorelease];
        fakeProvider.fakeIMAdView = banner;

        location = [[[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.1, 21.2)
                                                  altitude:11
                                        horizontalAccuracy:12.3
                                          verticalAccuracy:10
                                                 timestamp:[NSDate date]] autorelease];
        delegate stub_method("location").and_return(location);
    });

    it(@"should allow automatic metrics tracking", ^{
        event.enableAutomaticImpressionAndClickTracking should equal(YES);
    });

    context(@"when requesting an ad with a valid size", ^{
        it(@"should configure the ad correctly, tell it to fech and not tell the delegate anything just yet", ^{
            [event requestAdWithSize:MOPUB_BANNER_SIZE customEventInfo:nil];
            banner.loadedRequest should_not be_nil;
            banner.imAppId should equal(@"YOUR_INMOBI_APP_ID");
            banner.imAdSize should equal(IM_UNIT_320x50);
            banner.frame should equal(CGRectMake(0, 0, 320, 50));
            banner.refreshInterval should equal(REFRESH_INTERVAL_OFF);
            delegate should_not have_received(@selector(bannerCustomEvent:didLoadAd:));
            delegate should_not have_received(@selector(bannerCustomEvent:didFailToLoadAdWithError:));
        });

        it(@"should load the banner with a proper request object", ^{
            [event requestAdWithSize:MOPUB_BANNER_SIZE customEventInfo:nil];
            banner.loadedRequest should equal(request);

            request should have_received(@selector(setParamsDictionary:)).with(@{@"tp": @"c_mopub"});
            request should have_received(@selector(setLocationWithLatitude:longitude:accuracy:)).with(37.1f).and_with(21.2f).and_with(12.3f);
        });

        it(@"should support the rectangular size", ^{
            [event requestAdWithSize:MOPUB_MEDIUM_RECT_SIZE customEventInfo:nil];
            banner.frame should equal(CGRectMake(0, 0, 300, 250));
            banner.imAdSize should equal(IM_UNIT_300x250);
        });

        it(@"should support the leaderboard size", ^{
            [event requestAdWithSize:MOPUB_LEADERBOARD_SIZE customEventInfo:nil];
            banner.frame should equal(CGRectMake(0, 0, 728, 90));
            banner.imAdSize should equal(IM_UNIT_728x90);
        });
    });

    context(@"when requesting an ad with an invalid size", ^{
        beforeEach(^{
            [event requestAdWithSize:CGSizeMake(1, 2) customEventInfo:nil];
        });

        it(@"should (immediately) tell the delegate that it failed", ^{
            delegate should have_received(@selector(bannerCustomEvent:didFailToLoadAdWithError:)).with(event).and_with(nil);
        });
    });
});

SPEC_END
