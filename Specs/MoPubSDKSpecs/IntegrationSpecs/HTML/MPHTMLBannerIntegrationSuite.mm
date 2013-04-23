#import "MPAdView.h"
#import "MPAdConfigurationFactory.h"
#import "FakeMPAdWebView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@protocol ChocolateMPAdViewDelegate <MPAdViewDelegate>

- (void)chocolate:(NSDictionary *)sauce;

@end

SPEC_BEGIN(MPHTMLBannerIntegrationSuite)

describe(@"MPHTMLBannerIntegrationSuite", ^{
    __block FakeMPAdWebView *fakeAd;
    __block MPAdConfiguration *configuration;

    __block MPAdView *banner;
    __block id<CedarDouble, MPAdViewDelegate> delegate;
    __block UIViewController *presentingController;
    __block FakeMPAdServerCommunicator *communicator;

    beforeEach(^{
        presentingController = [[[UIViewController alloc] init] autorelease];
        delegate = nice_fake_for(@protocol(ChocolateMPAdViewDelegate));
        delegate stub_method(@selector(viewControllerForPresentingModalView)).and_return(presentingController);

        configuration = [MPAdConfigurationFactory defaultBannerConfiguration];

        fakeAd = [[[FakeMPAdWebView alloc] initWithFrame:CGRectZero] autorelease];
        fakeProvider.fakeMPAdWebView = fakeAd;

        banner = [[[MPAdView alloc] initWithAdUnitId:@"html_banner" size:MOPUB_BANNER_SIZE] autorelease];
        banner.delegate = delegate;
        [banner loadAd];

        communicator = fakeProvider.lastFakeMPAdServerCommunicator;
        [communicator receiveConfiguration:configuration];
    });

    it(@"should ask the ad to load and configure it correctly", ^{
        fakeAd.loadedHTMLString should equal(configuration.adResponseHTMLString);
        fakeAd.frame.size should equal(MOPUB_BANNER_SIZE);
    });

    it(@"should tell the ad to rotate", ^{
        [banner rotateToOrientation:UIInterfaceOrientationLandscapeLeft];
        (NSString *)fakeAd.executedJavaScripts[fakeAd.executedJavaScripts.count - 2] should contain(@"'orientation'");
    });

    context(@"when the ad loads succesfully", ^{
        beforeEach(^{
            [delegate reset_sent_messages];
            [fakeAd simulateLoadingAd];
        });

        it(@"should allow the ad to call down to the delegate via the custom method URL/API", ^{
            [fakeAd loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"mopub://custom?fnc=chocolate&data=%7B%22caramel%22%3A3%7D"]]];
            delegate should have_received(@selector(chocolate:)).with(@{@"caramel":@3});
        });

        it(@"should tell the delegate, show the ad, but *not* track an impression", ^{
            verify_fake_received_selectors(delegate, @[@"adViewDidLoadAd:"]);
            banner.subviews should equal(@[fakeAd]);
            banner.adContentViewSize should equal(fakeAd.frame.size);
            fakeProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
        });

        context(@"when the user taps the ad", ^{
            beforeEach(^{
                [delegate reset_sent_messages];
                [fakeAd simulateUserBringingUpModal];
            });

            it(@"should tell the delegate, but *not* track a click", ^{
                verify_fake_received_selectors(delegate, @[@"willPresentModalViewForAd:"]);
                fakeProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations should be_empty;
            });

            context(@"when the user dismisses the modal", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [fakeAd simulateUserDismissingModal];
                });

                it(@"should tell the delegate", ^{
                    verify_fake_received_selectors(delegate, @[@"didDismissModalViewForAd:"]);
                });
            });

            context(@"when the user leaves the application", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [fakeAd simulateUserLeavingApplication];
                });

                it(@"should tell the delegate", ^{
                    verify_fake_received_selectors(delegate, @[@"willLeaveApplicationFromAd:"]);
                });
            });
        });
    });

    context(@"when the ad fails to load", ^{
        beforeEach(^{
            [fakeAd simulateFailingToLoad];
        });

        it(@"should start the waterfall", ^{
            communicator.loadedURL should equal(configuration.failoverURL);
        });
    });
});

SPEC_END
