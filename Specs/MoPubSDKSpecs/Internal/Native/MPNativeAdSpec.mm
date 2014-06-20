#import "MPNativeAdRequest.h"
#import "MPNativeAd+Specs.h"
#import "MPNativeAdRendering.h"
#import "MPAdConfigurationFactory.h"
#import "NSJSONSerialization+MPAdditions.h"
#import "MPMoPubNativeAdAdapter.h"
#import "MPNativeAd+Internal.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPNativeAdSpec)

describe(@"MPNativeAd", ^{
    __block MPNativeAd *fakeAd;
    __block MPAdConfiguration *configuration;
    __block UIView<CedarDouble, MPNativeAdRendering> *fakeAdView;
    __block MPMoPubNativeAdAdapter *adAdapter;

    beforeEach(^{
        configuration = [MPAdConfigurationFactory defaultNativeAdConfiguration];

        NSDictionary *properties = [NSJSONSerialization mp_JSONObjectWithData:configuration.adResponseData options:0 clearNullObjects:YES error:nil];
        adAdapter = [[[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[[properties mutableCopy] autorelease]] autorelease];
        fakeAd = [[[MPNativeAd alloc] initWithAdAdapter:adAdapter] autorelease];
        fakeAdView = nice_fake_for(@protocol(MPNativeAdRendering));
        [MPNativeAd mp_clearTrackMetricURLCallsCount];
    });

    context(@"ad configuration", ^{

        it(@"should use the default requiredSecondsForImpression", ^{
            fakeAd.requiredSecondsForImpression should equal(1.0);
        });

        it(@"should configure properties correctly", ^{
            [fakeAd.properties allKeys] should contain(@"ctatext");
            [fakeAd.properties allKeys] should contain(@"iconimage");
            [fakeAd.properties allKeys] should contain(@"mainimage");
            [fakeAd.properties allKeys] should contain(@"text");
            [fakeAd.properties allKeys] should contain(@"title");
        });

        it(@"should have a default action URL", ^{
            fakeAd.defaultActionURL should equal(adAdapter.defaultActionURL);
        });

        it(@"should not have engagement or impression tracker URLS", ^{
            // It is not the responsibility of the mpnative ad to fill in the URLs.
            fakeAd.engagementTrackingURL should be_nil;
            fakeAd.impressionTrackers.count should equal(0);
        });

        context(@"star rating", ^{
            __block id<CedarDouble, MPNativeAdAdapter> fakeadAdapter;
            __block MPNativeAd *starRatingFakeAd;

            beforeEach(^{
                fakeadAdapter = nice_fake_for(@protocol(MPNativeAdAdapter));
                starRatingFakeAd = [[[MPNativeAd alloc] initWithAdAdapter:fakeadAdapter] autorelease];
            });

            it(@"should return a valid star rating object if the backing ad provides a valid value", ^{
                fakeadAdapter stub_method("properties").and_return(@{@"starrating":@4.5f});
                starRatingFakeAd.starRating.floatValue should equal(4.5f);
            });

            it(@"should return a valid star rating object if the backing ad provides the minimum valid value", ^{
                fakeadAdapter stub_method("properties").and_return(@{@"starrating":@0});
                starRatingFakeAd.starRating.floatValue should equal(0);
            });

            it(@"should return a valid star rating object if the backing ad provides the maximum valid value", ^{
                fakeadAdapter stub_method("properties").and_return(@{@"starrating":@5.0f});
                starRatingFakeAd.starRating.floatValue should equal(5.0f);
            });

            it(@"should return a nil star rating object if the backing ad does not provide a value", ^{
                fakeadAdapter stub_method("properties").and_return(@{});
                starRatingFakeAd.starRating should equal(nil);
            });

            it(@"should return a nil star rating object if the backing ad does not provide an NSNumber as the value", ^{
                fakeadAdapter stub_method("properties").and_return(@{@"starrating":@[@"hello"]});
                starRatingFakeAd.starRating should equal(nil);
            });

            it(@"should return a nil star rating object if the backing ad provides a value that's over the maximum", ^{
                fakeadAdapter stub_method("properties").and_return(@{@"starrating":@6.0f});
                starRatingFakeAd.starRating should equal(nil);
            });

            it(@"should return a nil star rating object if the backing ad provides a value that's less than the minimum", ^{
                fakeadAdapter stub_method("properties").and_return(@{@"starrating":@-1.34f});
                starRatingFakeAd.starRating should equal(nil);
            });
        });
    });

    context(@"when the ad loads successfully", ^{
        beforeEach(^{
            [fakeAd prepareForDisplayInView:fakeAdView];
        });

        it(@"should layout the ad's assets into the specified view", ^{
            fakeAdView should have_received(@selector(layoutAdAssets:));
        });
    });

    context(@"interaction with the ad", ^{
        __block UIViewController *rootController;

        beforeEach(^{
            rootController = [[[UIViewController alloc] init] autorelease];
            // Make sure it has an engagement tracking url.
            fakeAd.engagementTrackingURL = [NSURL URLWithString:@"http://www.mopub.com"];
        });

        it(@"should track click when displayContentForURL is called", ^{
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(0);
            [fakeAd displayContentForURL:nil rootViewController:rootController completion:nil];
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(1);
        });

        it(@"should call completion block with an error when displaying with a nil view controller", ^{
            __block BOOL wasSuccessful = YES;
            [fakeAd displayContentForURL:[NSURL URLWithString:@"http://www.mopub.com"] rootViewController:nil completion:^(BOOL success, NSError *error) {
                wasSuccessful = success;
            }];

            wasSuccessful should be_falsy;
        });

        it(@"should track click when displaying content from the non-URL version", ^{
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(0);
            [fakeAd displayContentFromRootViewController:nil completion:nil];
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(1);
        });

        it(@"should not track multiple clicks on the same ad", ^{
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(0);
            [fakeAd trackClick];
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(1);
            [fakeAd trackClick];
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(1);
        });

        it(@"should track for all impression URLs", ^{
            [fakeAd.impressionTrackers addObjectsFromArray:@[@"http://www.mopub.com", @"http://www.mopub.com/t", @"http://www.mopub.com/tt"]];
             [MPNativeAd mp_trackMetricURLCallsCount] should equal(0);
             [fakeAd trackImpression];
             [MPNativeAd mp_trackMetricURLCallsCount] should equal(3);
        });

        it(@"should not track multiple impressions on the same ad", ^{
            // Make sure it has one impression tracker URL.
            [fakeAd.impressionTrackers addObject:@"http://www.mopub.com"];
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(0);
            [fakeAd trackImpression];
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(1);
            [fakeAd trackImpression];
            [MPNativeAd mp_trackMetricURLCallsCount] should equal(1);
        });
    });

    context(@"when receiving messages along with a delegate that implements all protocol methods", ^{
        __block id<CedarDouble, MPNativeAdAdapter> mockadAdapter;
        __block MPNativeAd *nativeAd;

        beforeEach(^{
            mockadAdapter = nice_fake_for(@protocol(MPNativeAdAdapter));
            nativeAd = [[[MPNativeAd alloc] initWithAdAdapter:mockadAdapter] autorelease];
        });

        it(@"should forward track click to backing object", ^{
            [nativeAd trackClick];
            mockadAdapter should have_received(@selector(trackClick));
        });

        it(@"should forward track impression to backing object", ^{
            [nativeAd trackImpression];
            mockadAdapter should have_received(@selector(trackImpression));
        });

        it(@"should forward willAttachToView to backing object", ^{
            [nativeAd prepareForDisplayInView:nice_fake_for(@protocol(MPNativeAdRendering))];
            mockadAdapter should have_received(@selector(willAttachToView:));
        });

        it(@"should forward requiredSecondsForImpression to backing object", ^{
            [nativeAd requiredSecondsForImpression];
            mockadAdapter should have_received(@selector(requiredSecondsForImpression));
        });

        it(@"should forward displayContentForURL (URL version) to the adAdapter", ^{
            [nativeAd displayContentForURL:[NSURL URLWithString:@"http://www.mopub.com"] rootViewController:[[[UIViewController alloc] init] autorelease] completion:nil];
            mockadAdapter should have_received(@selector(displayContentForURL:rootViewController:completion:));
        });

        it(@"should forward displayContentForURL (no-URL version) to the adAdapter", ^{
            [nativeAd displayContentFromRootViewController:[[[UIViewController alloc] init] autorelease] completion:nil];
            mockadAdapter should have_received(@selector(displayContentForURL:rootViewController:completion:));
        });

        it(@"should forward properties to the adAdapter", ^{
            [nativeAd properties];
            mockadAdapter should have_received(@selector(properties));
        });

        it(@"should forward defaultActionURL to the adAdapter", ^{
            [nativeAd defaultActionURL];
            mockadAdapter should have_received(@selector(defaultActionURL));
        });
    });

    context(@"when receiving messages along with a delegate that implements none of the optional protocol methods", ^{
        __block id<CedarDouble, MPNativeAdAdapter> mockadAdapter;
        __block MPNativeAd *nativeAd;

        beforeEach(^{
            mockadAdapter = fake_for(@protocol(MPNativeAdAdapter));
            nativeAd = [[[MPNativeAd alloc] initWithAdAdapter:mockadAdapter] autorelease];
        });

        it(@"should not forward track click to backing object", ^{
            [nativeAd trackClick];
            mockadAdapter should_not have_received(@selector(trackClick));
        });

        it(@"should not forward track impression to backing object", ^{
            [nativeAd trackImpression];
            mockadAdapter should_not have_received(@selector(trackImpression));
        });

        it(@"should not forward willAttachToView to backing object", ^{
            [nativeAd prepareForDisplayInView:nice_fake_for(@protocol(MPNativeAdRendering))];
            mockadAdapter should_not have_received(@selector(willAttachToView:));
        });

        it(@"should not forward requiredSecondsForImpression to backing object", ^{
            [nativeAd requiredSecondsForImpression];
            mockadAdapter should_not have_received(@selector(requiredSecondsForImpression));
        });
    });
});

SPEC_END
