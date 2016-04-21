#import "MPiAdBannerCustomEvent.h"
#import "FakeADBannerView.h"
#import "FakeUIDevice.h"
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPiAdBannerCustomEvent (Spec)

- (ADBannerView *)bannerView;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

SPEC_BEGIN(MPiAdBannerCustomEventSpec)

describe(@"MPiAdBannerCustomEvent", ^{
    __block id<CedarDouble, MPBannerCustomEventDelegate> delegate;
    __block MPiAdBannerCustomEvent *event;
    __block FakeADBannerView *banner;
    __block FakeADBannerView *mediumRectangle;

    beforeEach(^{
        banner = [[FakeADBannerView alloc] initWithAdType:ADAdTypeBanner];
        fakeProvider.fakeADBannerView = banner.masquerade;

        mediumRectangle = [[FakeADBannerView alloc] initWithAdType:ADAdTypeMediumRectangle];
        fakeProvider.fakeADBannerViewMediumRectangle = mediumRectangle.masquerade;

        delegate = nice_fake_for(@protocol(MPBannerCustomEventDelegate));

        event = [[MPiAdBannerCustomEvent alloc] init];
        event.delegate = delegate;
    });

    it(@"should not allow automatic metrics tracking", ^{
        event.enableAutomaticImpressionAndClickTracking should equal(NO);
    });

    describe(@"requesting ads with different sizes", ^{
        context(@"on iPhone", ^{
            beforeEach(^{
                FakeUIDevice *fakeUIDevice = [[FakeUIDevice alloc] init];
                fakeUIDevice.userInterfaceIdiom = UIUserInterfaceIdiomPhone;
                fakeCoreProvider.fakeUIDevice = fakeUIDevice;
            });

            it(@"should return a banner ad when the height is at least that of a medium rectangle", ^{
                [event requestAdWithSize:CGSizeMake(300, 250) customEventInfo:nil];
                [banner simulateLoadingAd];
                delegate should have_received(@selector(bannerCustomEvent:didLoadAd:)).with(event).and_with(banner);
            });
        });

        context(@"on iPad", ^{
            beforeEach(^{
                FakeUIDevice *fakeUIDevice = [[FakeUIDevice alloc] init];
                fakeUIDevice.userInterfaceIdiom = UIUserInterfaceIdiomPad;
                fakeCoreProvider.fakeUIDevice = fakeUIDevice;
            });

            it(@"should return a medium rectangle ad when the height is at least that of a medium rectangle", ^{
                [event requestAdWithSize:CGSizeMake(300, 250) customEventInfo:nil];
                [mediumRectangle simulateLoadingAd];
                delegate should have_received(@selector(bannerCustomEvent:didLoadAd:)).with(event).and_with(mediumRectangle);
            });
        });
    });

    describe(@"tracking impressions", ^{
        beforeEach(^{
            [event requestAdWithSize:CGSizeZero customEventInfo:nil];
        });

        context(@"when an ad loads, and is not onscreen already", ^{
            beforeEach(^{
                [banner simulateLoadingAd];
            });

            it(@"should not track an impression", ^{
                delegate should_not have_received(@selector(trackImpression));
            });

            context(@"when the ad subsequently appears onscreen", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [event didDisplayAd];
                });

                it(@"should track an impression (only once)", ^{
                    delegate should have_received(@selector(trackImpression));

                    [delegate reset_sent_messages];
                    [event didDisplayAd];
                    delegate.sent_messages should be_empty;
                });

                context(@"when a new ad arrives", ^{
                    beforeEach(^{
                        [delegate reset_sent_messages];
                        [banner simulateLoadingAd];
                    });

                    it(@"should track an impression", ^{
                        delegate should have_received(@selector(trackImpression));
                    });
                });
            });
        });
    });

    describe(@"tracking clicks", ^{
        beforeEach(^{
            [event requestAdWithSize:CGSizeZero customEventInfo:nil];
        });

        it(@"should track a click at most once per loaded ad", ^{
            [banner simulateLoadingAd];
            [banner simulateUserInteraction];
            delegate should have_received(@selector(trackClick));

            [delegate reset_sent_messages];
            [banner simulateUserInteraction];
            delegate should_not have_received(@selector(trackClick));

            [banner simulateLoadingAd];
            [banner simulateUserInteraction];
            delegate should have_received(@selector(trackClick));
        });
    });

    context(@"when another iAd custom event exists at the same time", ^{
        beforeEach(^{
            // Allow the instance provider to create real ADBannerViews for this test.
            fakeProvider.fakeADBannerView = nil;
            fakeProvider.fakeADBannerViewMediumRectangle = nil;
        });

        context(@"when requesting an ad of the same size as that of the other custom event", ^{
            it(@"should share the same banner view instance as the other custom event", ^{
                // Re-initialize `event` so that it gets a real ADBannerView.
                event = [[MPiAdBannerCustomEvent alloc] init];
                event.delegate = delegate;

                id<CedarDouble, MPBannerCustomEventDelegate> anotherDelegate = nice_fake_for(@protocol(MPBannerCustomEventDelegate));
                MPiAdBannerCustomEvent *anotherCustomEvent = [[MPiAdBannerCustomEvent alloc] init];
                anotherCustomEvent.delegate = anotherDelegate;

                [event requestAdWithSize:CGSizeZero customEventInfo:nil];
                [anotherCustomEvent requestAdWithSize:CGSizeZero customEventInfo:nil];

                [event bannerView] should_not be_nil;
                [anotherCustomEvent bannerView] should_not be_nil;
                [event bannerView] should be_same_instance_as([anotherCustomEvent bannerView]);
            });
        });
    });
});

SPEC_END
