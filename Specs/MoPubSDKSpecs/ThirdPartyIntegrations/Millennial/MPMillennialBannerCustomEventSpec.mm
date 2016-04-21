#import "MPMillennialBannerCustomEvent.h"
#import <MMAdSDK/MMInlineAd.h>
#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPMillennialBannerCustomEvent (Specs)

@property (nonatomic, strong) MMInlineAd *mmInlineAds;
@property (nonatomic, assign) BOOL didTrackImpression;

@end

SPEC_BEGIN(MPMillennialBannerCustomEventSpec)

describe(@"MPMillennialBannerCustomEvent", ^{
    __block id<CedarDouble, MPBannerCustomEventDelegate> delegate;
    __block MPMillennialBannerCustomEvent *event;
    __block MMInlineAd *banner;
    __block NSDictionary *customEventInfo;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPBannerCustomEventDelegate));

        event = [[MPMillennialBannerCustomEvent alloc] init];
        event.delegate = delegate;

        customEventInfo = @{@"adUnitID": @"mmmmmmm", @"adWidth":@728, @"adHeight":@90};
    });

    subjectAction(^{
        [event requestAdWithSize:CGSizeZero customEventInfo:customEventInfo];
        banner = event.mmInlineAds;
    });

    it(@"should disallow automatic metrics tracking", ^{
        event.enableAutomaticImpressionAndClickTracking should equal(NO);
    });

    context(@"when asked to fetch a banner", ^{
        it(@"should set the banner's ad unit ID and mediator", ^{
            banner.placementId should equal(@"mmmmmmm");
            [[MMSDK sharedInstance] appSettings].mediator should equal(@"MPMillennialBannerCustomEvent");
        });

        context(@"the banner size", ^{
            context(@"when the banner size matches the regular banner size", ^{
                beforeEach(^{
                    customEventInfo = @{@"adUnitID": @"mmmmmmm", @"adWidth":@320, @"adHeight":@50};
                });

                it(@"should fetch a banner of the right size and type", ^{
                    banner.view.frame should equal(CGRectMake(0, 0, 320, 50));
                });
            });

            context(@"when the banner size matches the leaderboard banner size", ^{
                beforeEach(^{
                    customEventInfo = @{@"adUnitID": @"mmmmmmm", @"adWidth":@728, @"adHeight":@90};
                });

                it(@"should fetch a banner of the right size and type", ^{
                    banner.view.frame should equal(CGRectMake(0, 0, 728, 90));
                });
            });

            context(@"when the banner size matches the rectangle size", ^{
                beforeEach(^{
                    customEventInfo = @{@"adUnitID": @"mmmmmmm", @"adWidth":@300, @"adHeight":@250};
                });

                it(@"should fetch a banner of the right size and type", ^{
                    banner.view.frame should equal(CGRectMake(0, 0, 300, 250));
                });
            });

            context(@"when the size doesn't match one of the above", ^{
                beforeEach(^{
                    customEventInfo = @{@"adUnitID": @"mmmmmmm", @"adWidth":@370, @"adHeight":@250};
                });

                it(@"should fetch a banner of the 320x53 size and top type", ^{
                    banner.view.frame should equal(CGRectMake(0, 0, 320, 50));
                });
            });

            context(@"when the size is not present", ^{
                beforeEach(^{
                    customEventInfo = @{@"adUnitID": @"mmmmmmm"};
                });

                it(@"should fetch a banner of the 320x53 size and top type", ^{
                    banner.view.frame should equal(CGRectMake(0, 0, 320, 50));
                });
            });
        });
    });

    context(@"when the banner successfully loads", ^{
        beforeEach(^{
            [delegate reset_sent_messages];
            [event inlineAdRequestDidSucceed:banner];
        });

        it(@"should alert the delegate and track an impression", ^{
            delegate should have_received(@selector(bannerCustomEvent:didLoadAd:));
            delegate should have_received(@selector(trackImpression));
        });

        it(@"should not double track impressions", ^{
            [delegate reset_sent_messages];
            [event inlineAdRequestDidSucceed:banner];
            delegate should_not have_received(@selector(trackImpression));
        });
    });

    context(@"when the banner fails to load", ^{
        beforeEach(^{
            [delegate reset_sent_messages];
            [event inlineAd:banner requestDidFailWithError:[NSError errorWithDomain:@"fake" code:1 userInfo:nil]];
        });

        it(@"should alert the delegate and not track an impression", ^{
            delegate should have_received(@selector(bannerCustomEvent:didFailToLoadAdWithError:));
            delegate should_not have_received(@selector(trackImpression));
        });
    });
});

SPEC_END
