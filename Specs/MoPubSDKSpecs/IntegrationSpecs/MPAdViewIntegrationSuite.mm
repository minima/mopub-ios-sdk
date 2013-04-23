#import "FakeBannerCustomEvent.h"
#import "MPAdView.h"
#import "MPAdConfigurationFactory.h"
using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

typedef FakeBannerCustomEvent *(^FakeBannerCustomEventReturningBlock)();

SPEC_BEGIN(MPAdViewIntegrationSuite)

describe(@"MPAdViewIntegrationSuite", ^{
    __block FakeBannerCustomEvent *requestingEvent;
    __block MPAdConfiguration *requestingConfiguration;
    __block FakeBannerCustomEvent *onscreenEvent;
    __block MPAdConfiguration *onscreenConfiguration;

    __block MPAdView *banner;
    __block id<CedarDouble, MPAdViewDelegate> delegate;
    __block FakeMPAdServerCommunicator *communicator;
    __block UIViewController *presentingController;
    __block UIInterfaceOrientation currentOrientation;
    __block FakeBannerCustomEventReturningBlock moveRequestingToOnscreen;

    ///////////////// BEGIN SHARED EXAMPLES //////////////////////

    sharedExamplesFor(@"a banner that is loading an ad", ^(NSDictionary *sharedContext) {
        it(@"should ignore the load", ^{
            [communicator resetLoadedURL];
            [banner loadAd];

            fakeProvider.lastFakeMPAdServerCommunicator.loadedURL should be_nil;
        });

        itShouldBehaveLike(@"a banner that can be immediately refreshed");
    });

    sharedExamplesFor(@"a banner that is not loading an ad", ^(NSDictionary *sharedContext) {
        it(@"should allow the ad to load", ^{
            [communicator resetLoadedURL];
            [banner loadAd];

            fakeProvider.lastFakeMPAdServerCommunicator.loadedURL.absoluteString should contain(@"custom_event");
        });

        itShouldBehaveLike(@"a banner that can be immediately refreshed");
    });

    sharedExamplesFor(@"a banner that can be immediately refreshed", ^(NSDictionary *sharedContext) {
        beforeEach(^{
            [delegate reset_sent_messages];
            [communicator resetLoadedURL];
            [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification
                                                                object:[UIApplication sharedApplication]];
        });

        it(@"should forcibly fetch a new ad", ^{
            fakeProvider.lastFakeMPAdServerCommunicator.loadedURL.absoluteString should contain(@"custom_event");
        });

        it(@"should not inform the delegate, or display the ad, if the 'canceled' adapter successfully loads", ^{
            if (requestingEvent) {
                [requestingEvent simulateLoadingAd];
                delegate.sent_messages should be_empty;
                banner.subviews.lastObject should_not equal(requestingEvent.view);
            }
        });

        it(@"should not inform the delegate, if the 'canceled' adapter fails to load", ^{
            if (requestingEvent) {
                [requestingEvent simulateFailingToLoad];
                delegate.sent_messages should be_empty;
            }
        });

        it(@"should not 'cancel' the onscreen adapter and should continue listening to it", ^{
            if (onscreenEvent) {
                [onscreenEvent simulateUserTap];
                banner.subviews.lastObject should equal(onscreenEvent.view);
                verify_fake_received_selectors(delegate, @[@"willPresentModalViewForAd:"]);
            }
        });
    });

    sharedExamplesFor(@"a banner that tells its events to rotate", ^(NSDictionary *sharedContext) {
        beforeEach(^{
            [banner rotateToOrientation:UIInterfaceOrientationPortrait];
        });

        it(@"should tell the custom event (even while it's loading)", ^{
            if (requestingEvent) {
                requestingEvent.orientation should equal(UIInterfaceOrientationPortrait);
            }
            if (onscreenEvent) {
                onscreenEvent.orientation should equal(UIInterfaceOrientationPortrait);
            }
        });
    });

    sharedExamplesFor(@"a banner that loads the failover URL", ^(NSDictionary *sharedContext) {
        it(@"should request the failover URL", ^{
            communicator.loadedURL should equal(requestingConfiguration.failoverURL);
        });

        it(@"should not tell the delegate anything", ^{
            delegate.sent_messages should be_empty;
        });

        itShouldBehaveLike(@"a banner that is loading an ad");

        context(@"if the failover URL returns clear", ^{
            __block MPAdConfiguration *clearConfiguration;

            beforeEach(^{
                [delegate reset_sent_messages];

                clearConfiguration = [MPAdConfigurationFactory defaultBannerConfigurationWithNetworkType:@"clear"];
                clearConfiguration.refreshInterval = 5;
                [communicator receiveConfiguration:clearConfiguration];
                [communicator resetLoadedURL];
            });

            it(@"should tell the delegate that it failed, schedule a new refresh timer, and leave the onscreen event in place (if present)", ^{
                verify_fake_received_selectors(delegate, @[@"adViewDidFailToLoadAd:"]);

                [communicator resetLoadedURL];
                [fakeProvider advanceMPTimers:clearConfiguration.refreshInterval];
                communicator.loadedURL should_not be_nil;

                if (onscreenEvent) {
                    [onscreenEvent simulateUserTap];
                    banner.subviews.lastObject should equal(onscreenEvent.view);
                    verify_fake_received_selectors(delegate, @[@"willPresentModalViewForAd:"]);
                }
            });

            itShouldBehaveLike(@"a banner that is not loading an ad");
        });
    });

    sharedExamplesFor(@"a banner that presents the onscreen event", ^(NSDictionary *sharedContext) {
        itShouldBehaveLike(@"a banner that is not loading an ad");
        itShouldBehaveLike(@"a banner that tells its events to rotate");

        it(@"should tell the ad view delegate, put the ad view on the screen, return the correct ad content size, track an impression, schedule a refresh timer, and set the orientation on the ad", ^{
            delegate should have_received(@selector(adViewDidLoadAd:));
            banner.subviews should equal(@[onscreenEvent.view]);
            banner.adContentViewSize should equal(onscreenEvent.view.frame.size);
            fakeProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should equal(@[onscreenConfiguration]);

            [communicator resetLoadedURL];
            [fakeProvider advanceMPTimers:onscreenConfiguration.refreshInterval];
            communicator.loadedURL should_not be_nil;

            onscreenEvent.orientation should equal(currentOrientation);
        });

        context(@"if the onscreen event claims to load again", ^{
            it(@"should ignore those events", ^{
                [delegate reset_sent_messages];
                [fakeProvider.sharedFakeMPAnalyticsTracker reset];
                [banner.subviews.lastObject removeFromSuperview];
                [onscreenEvent simulateLoadingAd];

                delegate.sent_messages should be_empty;
                banner.subviews should be_empty;
                fakeProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
            });
        });

        context(@"if the onscreen event fails while it is onscreen", ^{
            it(@"should tell the delegate, remove the ad, ignore it in the future, and start loading right away", ^{
                [communicator resetLoadedURL];
                [delegate reset_sent_messages];
                [onscreenEvent simulateFailingToLoad];

                verify_fake_received_selectors(delegate, @[@"adViewDidFailToLoadAd:"]);
                banner.subviews should be_empty;
                fakeProvider.lastFakeMPAdServerCommunicator.loadedURL.absoluteString should contain(@"custom_event");

                [delegate reset_sent_messages];
                [onscreenEvent simulateLoadingAd];
                [onscreenEvent simulateUserTap];
                delegate.sent_messages should be_empty;
            });
        });
    });

    ///////////////// BEGIN SPECS //////////////////////

    beforeEach(^{
        currentOrientation = UIInterfaceOrientationLandscapeRight;
        onscreenEvent = nil;
        requestingEvent = nil;
        requestingConfiguration = nil;
        onscreenConfiguration = nil;

        presentingController = [[[UIViewController alloc] init] autorelease];
        delegate = nice_fake_for(@protocol(MPAdViewDelegate));
        delegate stub_method(@selector(viewControllerForPresentingModalView)).and_return(presentingController);

        banner = [[[MPAdView alloc] initWithAdUnitId:@"custom_event" size:MOPUB_BANNER_SIZE] autorelease];
        banner.delegate = delegate;
        [banner rotateToOrientation:currentOrientation];

        moveRequestingToOnscreen = [^{
            FakeBannerCustomEvent *originalOnscreenEvent = onscreenEvent;
            onscreenEvent = requestingEvent;
            onscreenConfiguration = requestingConfiguration;
            requestingEvent = nil;
            requestingConfiguration= nil;

            return originalOnscreenEvent;
        } copy];
    });

    context(@"when loading an ad", ^{
        beforeEach(^{
            [banner loadAd];

            communicator = fakeProvider.lastFakeMPAdServerCommunicator;
            communicator.loadedURL.absoluteString should contain(@"custom_event");
        });

        itShouldBehaveLike(@"a banner that is loading an ad");

        context(@"when the communicator fails", ^{
            beforeEach(^{
                [communicator failWithError:[NSErrorFactory genericError]];
            });

            it(@"should schedule the default refresh timer and make a new request when it fires", ^{
                [communicator resetLoadedURL];
                [fakeProvider advanceMPTimers:DEFAULT_BANNER_REFRESH_INTERVAL];
                communicator.loadedURL.absoluteString should contain(@"custom_event");
            });

            itShouldBehaveLike(@"a banner that is not loading an ad");
        });

        context(@"when the communicator succeeds", ^{
            beforeEach(^{
                requestingEvent = [[[FakeBannerCustomEvent alloc] initWithFrame:CGRectMake(0, 0, 20, 30)] autorelease];
                fakeProvider.fakeBannerCustomEvent = requestingEvent;

                requestingConfiguration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"FakeBannerCustomEvent"];
                requestingConfiguration.customEventClassData = @{@"why": @"not"};
                requestingConfiguration.refreshInterval = 12;

                [communicator receiveConfiguration:requestingConfiguration];
            });

            it(@"should tell the custom event to load the ad, with the appropriate size", ^{
                requestingEvent.size should equal(MOPUB_BANNER_SIZE);
                requestingEvent.customEventInfo should equal(requestingConfiguration.customEventClassData);
            });

            itShouldBehaveLike(@"a banner that is loading an ad");
            itShouldBehaveLike(@"a banner that tells its events to rotate");

            context(@"when the ad fails to load", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];
                    [communicator resetLoadedURL];
                    [fakeProvider advanceMPTimers:BANNER_TIMEOUT_INTERVAL];
                });

                itShouldBehaveLike(@"a banner that loads the failover URL");
            });

            context(@"when the ad loads successfully", ^{
                beforeEach(^{
                    [delegate reset_sent_messages];

                    [requestingEvent simulateLoadingAd];
                    moveRequestingToOnscreen();
                });

                itShouldBehaveLike(@"a banner that presents the onscreen event");

                // ** INTERACTING WITH THE ONSCREEN AD **
                context(@"when the user taps the ad", ^{
                    beforeEach(^{
                        [delegate reset_sent_messages];
                        [onscreenEvent simulateUserTap];
                    });

                    it(@"should tell the delegate and track a click (only once), and present the modal with the correct view controller", ^{
                        verify_fake_received_selectors(delegate, @[@"willPresentModalViewForAd:"]);
                        fakeProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations should equal(@[onscreenConfiguration]);
                        [onscreenEvent simulateUserTap];
                        fakeProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations should equal(@[onscreenConfiguration]);
                        verify_fake_received_selectors(delegate, @[@"willPresentModalViewForAd:"]);

                        onscreenEvent.presentingViewController should equal(presentingController);
                    });

                    it(@"should tell the delegate when the user finishes playing with the ad", ^{
                        [delegate reset_sent_messages];
                        [onscreenEvent simulateUserEndingInteraction];
                        verify_fake_received_selectors(delegate, @[@"didDismissModalViewForAd:"]);
                    });

                    it(@"should tell the delegate when the user leaves the application from the", ^{
                        [delegate reset_sent_messages];
                        [onscreenEvent simulateUserLeavingApplication];
                        verify_fake_received_selectors(delegate, @[@"willLeaveApplicationFromAd:"]);
                    });

                    it(@"should tell the delegate that the modal has been dismissed if the ad fails", ^{
                        [delegate reset_sent_messages];
                        [onscreenEvent simulateFailingToLoad];
                        verify_fake_received_selectors(delegate, @[@"adViewDidFailToLoadAd:", @"didDismissModalViewForAd:"]);
                    });

                    itShouldBehaveLike(@"a banner that is not loading an ad");
                });

                // ** LOADING ANOTHER AD IN THE BACKGROUND **
                context(@"when the refresh timer fires", ^{
                    beforeEach(^{
                        [communicator resetLoadedURL];
                        [fakeProvider advanceMPTimers:onscreenConfiguration.refreshInterval];
                        communicator.loadedURL.absoluteString should contain(@"custom_event");

                        requestingEvent = [[[FakeBannerCustomEvent alloc] initWithFrame:CGRectMake(0, 0, 40, 10)] autorelease];
                        fakeProvider.fakeBannerCustomEvent = requestingEvent;
                        requestingConfiguration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"FakeBannerCustomEvent"];
                        requestingConfiguration.customEventClassData = @{@"how": @"now"};
                        requestingConfiguration.refreshInterval = 32;

                        [communicator receiveConfiguration:requestingConfiguration];
                    });

                    it(@"should keep informing the delegate about events of the onscreen ad while loading the new ad in the background", ^{
                        [onscreenEvent simulateUserTap];
                        delegate should have_received(@selector(willPresentModalViewForAd:));
                    });

                    itShouldBehaveLike(@"a banner that is loading an ad");
                    itShouldBehaveLike(@"a banner that tells its events to rotate");

                    context(@"when the requesting ad fails to arrive", ^{
                        beforeEach(^{
                            [delegate reset_sent_messages];
                            [communicator resetLoadedURL];
                            [fakeProvider advanceMPTimers:BANNER_TIMEOUT_INTERVAL];
                        });

                        itShouldBehaveLike(@"a banner that loads the failover URL");
                    });

                    context(@"when the requesting ad succesfully arrives", ^{
                        __block FakeBannerCustomEvent *originalOnscreenEvent;

                        beforeEach(^{
                            [fakeProvider.sharedFakeMPAnalyticsTracker reset];
                            [delegate reset_sent_messages];
                            [requestingEvent simulateLoadingAd];

                            originalOnscreenEvent = moveRequestingToOnscreen();
                        });

                        itShouldBehaveLike(@"a banner that presents the onscreen event");

                        it(@"should ignore any messages from the original onscreen event", ^{
                            [delegate reset_sent_messages];
                            [originalOnscreenEvent simulateUserTap];
                            [originalOnscreenEvent simulateFailingToLoad];
                            delegate.sent_messages should be_empty;
                        });
                    });

                    // ** EDGE CASES WHEN THE BACKGROUND AD ARRIVES AND THE MODAL IS UP **
                    context(@"when the the user starts playing with a modal", ^{
                        beforeEach(^{
                            [onscreenEvent simulateUserTap];
                            [delegate reset_sent_messages];
                        });

                        context(@"and then the ad arrives", ^{
                            beforeEach(^{
                                [fakeProvider.sharedFakeMPAnalyticsTracker reset];
                                [requestingEvent simulateLoadingAd];
                            });

                            it(@"should not display the requesting ad just yet", ^{
                                delegate.sent_messages should be_empty;
                                banner.subviews should equal(@[onscreenEvent.view]);
                                banner.adContentViewSize should equal(onscreenEvent.view.frame.size);
                                fakeProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should be_empty;
                            });

                            itShouldBehaveLike(@"a banner that is loading an ad");

                            context(@"and then the user dismisses the onscreen ad's modal content", ^{
                                beforeEach(^{
                                    [onscreenEvent simulateUserEndingInteraction];
                                    moveRequestingToOnscreen();
                                });

                                itShouldBehaveLike(@"a banner that presents the onscreen event");
                            });

                            context(@"and then the onscreen ad manages to fail", ^{
                                beforeEach(^{
                                    [communicator resetLoadedURL];
                                    [onscreenEvent simulateFailingToLoad];
                                    moveRequestingToOnscreen();
                                });

                                it(@"should not start loading immediately (this is the default behavior when the ad fails, however we are in a situation where we already have a requesting adapter ready to go)", ^{
                                    communicator.loadedURL should be_nil;
                                });

                                itShouldBehaveLike(@"a banner that presents the onscreen event");
                            });
                        });

                        context(@"and the user dismisses the app, and the resulting forced refresh resolves with an ad", ^{
                            beforeEach(^{
                                [onscreenEvent simulateUserLeavingApplication];
                                [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillEnterForegroundNotification
                                                                                    object:[UIApplication sharedApplication]];
                                [communicator receiveConfiguration:requestingConfiguration];
                                [requestingEvent simulateLoadingAd];

                            });

                            it(@"should still not show the ad until the user dismisses the onscreen ad's modal content", ^{
                                banner.subviews should equal(@[onscreenEvent.view]);
                            });

                            context(@"when the user (finally) dimisses the onscreen ad's modal content", ^{
                                beforeEach(^{
                                    [fakeProvider.sharedFakeMPAnalyticsTracker reset];
                                    [onscreenEvent simulateUserEndingInteraction];
                                    moveRequestingToOnscreen();
                                });
                                itShouldBehaveLike(@"a banner that presents the onscreen event");
                            });
                        });

                        context(@"and the user dismisses the onscreen ad's modal content and *then* the requesting ad arrives", ^{
                            beforeEach(^{
                                [onscreenEvent simulateUserEndingInteraction];
                                [fakeProvider.sharedFakeMPAnalyticsTracker reset];

                                banner.subviews should equal(@[onscreenEvent.view]); //don't mess with the onscreen ad just yet

                                [requestingEvent simulateLoadingAd];
                                moveRequestingToOnscreen();
                            });

                            itShouldBehaveLike(@"a banner that presents the onscreen event");
                        });

                        context(@"and the onscreen ad manages to fail and *then* the requesting ad arrives", ^{
                            beforeEach(^{
                                [communicator resetLoadedURL];
                                [fakeProvider.sharedFakeMPAnalyticsTracker reset];
                                [delegate reset_sent_messages];
                                [onscreenEvent simulateFailingToLoad];

                                banner.subviews should be_empty; //the onscreen event was removed
                                communicator.loadedURL should be_nil; //shouldn't start loading 'cause w'ere mid-load

                                [delegate reset_sent_messages];
                                [requestingEvent simulateLoadingAd];
                                moveRequestingToOnscreen();
                            });

                            itShouldBehaveLike(@"a banner that presents the onscreen event");
                        });
                    });
                });

                context(@"when the user tries to load again, and *then* the refresh timer fires", ^{
                    beforeEach(^{
                        [banner loadAd];
                        [communicator resetLoadedURL];
                        [fakeProvider advanceMPTimers:onscreenConfiguration.refreshInterval];
                    });

                    it(@"should not restart the load (because it is already loading)", ^{
                        communicator.loadedURL should be_nil;
                    });

                    itShouldBehaveLike(@"a banner that is loading an ad");
                });
            });
        });
    });

    context(@"when told to ignore auto refresh", ^{
        beforeEach(^{
            banner.ignoresAutorefresh = YES;

            [banner loadAd];

            communicator = fakeProvider.lastFakeMPAdServerCommunicator;
            communicator.loadedURL.absoluteString should contain(@"custom_event");
        });

        context(@"when the communicator fails", ^{
            beforeEach(^{
                [communicator failWithError:nil];
            });

            it(@"should nonetheless schedule a refresh timer (with the default time interval)", ^{
                [communicator resetLoadedURL];
                [fakeProvider advanceMPTimers:DEFAULT_BANNER_REFRESH_INTERVAL];
                communicator.loadedURL should_not be_nil;
            });
        });

        context(@"when the waterfall eventually fails to load", ^{
            beforeEach(^{
                requestingConfiguration = [MPAdConfigurationFactory defaultBannerConfigurationWithNetworkType:kAdTypeClear];
                requestingConfiguration.refreshInterval = 36;
                [communicator receiveConfiguration:requestingConfiguration];
            });

            it(@"should nonetheless schedule a refresh timer (with the configuration's time interval)", ^{
                [communicator resetLoadedURL];
                [fakeProvider advanceMPTimers:36];
                communicator.loadedURL should_not be_nil;
            });
        });

        context(@"when the ad succesfully loads", ^{
            beforeEach(^{
                requestingEvent = [[[FakeBannerCustomEvent alloc] initWithFrame:CGRectMake(0, 0, 20, 30)] autorelease];
                fakeProvider.fakeBannerCustomEvent = requestingEvent;

                requestingConfiguration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"FakeBannerCustomEvent"];
                requestingConfiguration.refreshInterval = 36;

                [communicator receiveConfiguration:requestingConfiguration];

                [requestingEvent simulateLoadingAd];
            });

            it(@"should not schedule a refresh timer", ^{
                [communicator resetLoadedURL];
                [fakeProvider advanceMPTimers:36];
                communicator.loadedURL should be_nil;
            });
        });
    });
});

SPEC_END
