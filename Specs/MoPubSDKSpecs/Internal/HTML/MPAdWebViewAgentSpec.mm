#import "MPAdWebViewAgent.h"
#import "MPAdDestinationDisplayAgent.h"
#import "MPAdWebView.h"
#import "MPAdConfigurationFactory.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@protocol SassyProtocol <NSObject>
- (void)mySassyMethod:(NSDictionary *)sass;
@end

@protocol VerySassyProtocol <SassyProtocol>
- (void)mySassyMethod;
@end

SPEC_BEGIN(MPAdWebViewAgentSpec)

describe(@"MPAdWebViewAgent", ^{
    __block MPAdWebViewAgent *agent;
    __block id<CedarDouble, MPAdWebViewAgentDelegate> delegate;
    __block MPAdConfiguration *configuration;
    __block MPAdWebView *webView;
    __block MPAdDestinationDisplayAgent *destinationDisplayAgent;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPAdWebViewAgentDelegate));

        destinationDisplayAgent = nice_fake_for([MPAdDestinationDisplayAgent class]);
        fakeProvider.fakeMPAdDestinationDisplayAgent = destinationDisplayAgent;

        agent = [[[MPAdWebViewAgent alloc] initWithAdWebViewFrame:CGRectMake(0,0,30,20)
                                                         delegate:delegate
                                             customMethodDelegate:nil] autorelease];
        webView = agent.view;
        configuration = [MPAdConfigurationFactory defaultBannerConfiguration];
    });

    describe(@"when the configuration is loaded", ^{
        subjectAction(^{ [agent loadConfiguration:configuration]; });

        describe(@"setting the frame", ^{
            context(@"when the frame sizes are valid", ^{
                it(@"should set its frame", ^{
                    agent.view.frame.size.width should equal(320);
                    agent.view.frame.size.height should equal(50);
                });
            });

            context(@"when the frame sizes are invalid", ^{
                beforeEach(^{
                    configuration.preferredSize = CGSizeMake(0, 0);
                });

                it(@"should not set its frame", ^{
                    agent.view.frame.size.width should equal(30);
                    agent.view.frame.size.height should equal(20);
                });
            });
        });

        describe(@"setting scrollability", ^{
            context(@"when the configuration says no", ^{
                beforeEach(^{
                    configuration.scrollable = NO;
                });

                it(@"should disable scrolling", ^{
                    agent.view.scrollView.scrollEnabled should equal(NO);
                });
            });

            context(@"when the configuration says yes", ^{
                beforeEach(^{
                    configuration.scrollable = YES;
                });

                it(@"should enable scrolling", ^{
                    agent.view.scrollView.scrollEnabled should equal(YES);
                });
            });
        });

        describe(@"loading webview data", ^{
            it(@"should load the ad's HTML data into the webview", ^{
                agent.view.loadedHTMLString should equal(@"Publisher's Ad");
            });
        });
    });

    describe(@"MPAdDestinationDisplayAgentDelegate", ^{
        context(@"when asked for a view controller to present modal views", ^{
            it(@"should ask the MPAdWebViewAgentDelegate for one", ^{
                UIViewController *presentingViewController = [[[UIViewController alloc] init] autorelease];
                delegate stub_method("viewControllerForPresentingModalView").and_return(presentingViewController);
                [agent viewControllerForPresentingModalView] should equal(presentingViewController);
            });
        });

        context(@"when a modal is presented", ^{
            it(@"should tell the delegate", ^{
                [agent displayAgentWillPresentModal];
                delegate should have_received(@selector(adActionWillBegin:)).with(agent.view);
            });
        });

        context(@"when a modal is dismissed", ^{
            it(@"should tell the delegate", ^{
                [agent displayAgentDidDismissModal];
                delegate should have_received(@selector(adActionDidFinish:)).with(agent.view);
            });
        });

        context(@"when leaving the application", ^{
            it(@"should tell the delegate", ^{
                [agent displayAgentWillLeaveApplication];
                delegate should have_received(@selector(adActionWillLeaveApplication:)).with(agent.view);
            });
        });
    });

    describe(@"handling webview navigation", ^{
        __block NSURL *URL;

        subjectAction(^{ [agent loadConfiguration:configuration]; });

        context(@"when told to stop handling requests", ^{
            beforeEach(^{
                [agent stopHandlingRequests];
                URL = [NSURL URLWithString:@"mopub://close"];
            });

            it(@"should never load anything", ^{
                [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                delegate should_not have_received(@selector(adDidClose:)).with(agent.view);
            });

            context(@"when told to continue handling requests", ^{
                it(@"should load things again", ^{
                    [agent continueHandlingRequests];
                    [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                    delegate should have_received(@selector(adDidClose:)).with(agent.view);
                });
            });
        });

        context(@"when the URL scheme is mopub://", ^{
            context(@"when the host is 'close'", ^{
                it(@"should tell the delegate that adDidClose:", ^{
                    NSURL *URL = [NSURL URLWithString:@"mopub://close"];
                    [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                    delegate should have_received(@selector(adDidClose:)).with(agent.view);
                });
            });

            context(@"when the host is 'finishLoad'", ^{
                it(@"should tell the delegate that adDidFinishLoadingAd:", ^{
                    NSURL *URL = [NSURL URLWithString:@"mopub://finishLoad"];
                    [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                    delegate should have_received(@selector(adDidFinishLoadingAd:)).with(agent.view);
                });
            });

            context(@"when the host is 'failLoad'", ^{
                it(@"should tell the delegate that adDidFailToLoadAd:", ^{
                    NSURL *URL = [NSURL URLWithString:@"mopub://failLoad"];
                    [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                    delegate should have_received(@selector(adDidFailToLoadAd:)).with(agent.view);
                });
            });

            context(@"when the host is 'custom'", ^{
                beforeEach(^{
                    URL = [NSURL URLWithString:@"mopub://custom?fnc=mySassyMethod&data=%7B%22foo%22%3A3%7D"];
                });

                context(@"when the custom method delegate responds to -mySassyMethod (no arguments)", ^{
                    it(@"should call -mySassyMethod on the custom method delegate", ^{
                        id<CedarDouble, VerySassyProtocol> customMethodDelegate = nice_fake_for(@protocol(VerySassyProtocol));
                        agent.customMethodDelegate = customMethodDelegate;
                        [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);

                        customMethodDelegate should have_received("mySassyMethod");
                    });
                });

                context(@"when the custom method delegate responds to -mySassyMethod: but not -mySassyMethod", ^{
                    it(@"should call -mySassyMethod: on the custom method delegate and pass in data", ^{
                        id<CedarDouble, VerySassyProtocol> customMethodDelegate = nice_fake_for(@protocol(SassyProtocol));
                        agent.customMethodDelegate = customMethodDelegate;
                        [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);

                        customMethodDelegate should have_received("mySassyMethod:").with(@{@"foo": @3});
                    });
                });

                context(@"when the custom method delegate responds to neither method", ^{
                    it(@"should not blow up", ^{
                        id customMethodDelegate = [[[NSObject alloc] init] autorelease];
                        agent.customMethodDelegate = customMethodDelegate;
                        [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                    });
                });
            });

            context(@"when the host is something else", ^{
                beforeEach(^{
                    URL = [NSURL URLWithString:@"mopub://other"];
                });

                it(@"should not blow up and prevent the web view from handling the URL", ^{
                    [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                });
            });
        });

        context(@"when the scheme is not mopub", ^{
            beforeEach(^{
                URL = [NSURL URLWithString:@"http://yay.com"];
            });

            context(@"when navigation should not be intercepted", ^{
                beforeEach(^{
                    configuration.shouldInterceptLinks = NO;
                });

                it(@"should tell the webview to load the URL", ^{
                    [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(YES);
                });
            });

            context(@"when navigation should be intercepted", ^{
                beforeEach(^{
                    configuration.shouldInterceptLinks = YES;
                });

                context(@"when the navigation type is a click", ^{
                    it(@"should ask an ad destination display agent to handle the URL, prepended with a click tracker", ^{
                        NSURL *expectedRedirectURL = [NSURL URLWithString:@"http://ads.mopub.com/m/clickThroughTracker?a=1&r=http%3A%2F%2Fyay.com"];

                        [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked] should equal(NO);
                        destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(expectedRedirectURL);
                    });
                });

                context(@"when the navigation type is Other", ^{
                    context(@"when the URL has the 'click detection' URL prefix", ^{
                        beforeEach(^{
                            URL = [NSURL URLWithString:@"http://publisher.com/foo"];
                        });

                        it(@"should ask an ad destination display agent to handle the URL, prepended with a click tracker", ^{
                            NSURL *expectedRedirectURL = [NSURL URLWithString:@"http://ads.mopub.com/m/clickThroughTracker?a=1&r=http%3A%2F%2Fpublisher.com%2Ffoo"];

                            [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(NO);
                            destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(expectedRedirectURL);
                        });
                    });

                    context(@"otherwise", ^{
                        it(@"should tell the webview to load the URL", ^{
                            URL = [NSURL URLWithString:@"http://not-publisher.com/foo"];

                            [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeOther] should equal(YES);
                            destinationDisplayAgent should_not have_received(@selector(displayDestinationForURL:));
                        });
                    });
                });

                context(@"when the navigation type is something else", ^{
                    it(@"should tell the webview to load the URL", ^{
                        [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeReload] should equal(YES);
                        destinationDisplayAgent should_not have_received(@selector(displayDestinationForURL:));
                    });
                });

                context(@"when the click tracker is missing", ^{
                    beforeEach(^{
                        configuration.clickTrackingURL = nil;
                    });

                    it(@"should ask an ad destination display agent to handle the URL, without prepending the click tracker", ^{
                        [agent webView:agent.view shouldStartLoadWithRequest:[NSURLRequest requestWithURL:URL] navigationType:UIWebViewNavigationTypeLinkClicked] should equal(NO);
                        destinationDisplayAgent should have_received(@selector(displayDestinationForURL:)).with(URL);
                    });
                });
            });
        });
    });

    describe(@"when orientations change", ^{
        subjectAction(^{ [agent loadConfiguration:configuration]; });

        it(@"should tell the web view via javascript", ^{
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
            [agent rotateToOrientation:UIInterfaceOrientationLandscapeRight];
            NSString *JS = [agent.view executedJavaScripts][0];
            JS should contain(@"return 90");
            JS = [agent.view executedJavaScripts][1];
            JS should contain(@"width=320");
        });
    });

    describe(@"invoking JS", ^{
        subjectAction(^{ [agent loadConfiguration:configuration]; });

        it(@"should support MPAdWebViewEventAdDidAppear", ^{
            [agent invokeJavaScriptForEvent:MPAdWebViewEventAdDidAppear];
            [agent.view executedJavaScripts][0] should equal(@"webviewDidAppear();");
        });

        it(@"should support MPAdWebViewEventAdDidDisappear", ^{
            [agent invokeJavaScriptForEvent:MPAdWebViewEventAdDidDisappear];
            [agent.view executedJavaScripts][0] should equal(@"webviewDidClose();");
        });
    });
});

SPEC_END
