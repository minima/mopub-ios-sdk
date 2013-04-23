#import "MPAdDestinationDisplayAgent.h"
#import "MPProgressOverlayView.h"
#import "MPAdBrowserController.h"
#import "MPURLResolver.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

typedef void (^URLVerificationBlock)(NSURL *URL);

SPEC_BEGIN(MPAdDestinationDisplayAgentSpec)

describe(@"MPAdDestinationDisplayAgent", ^{
    __block MPAdDestinationDisplayAgent *agent;
    __block id<CedarDouble, MPAdDestinationDisplayAgentDelegate> delegate;
    __block MPURLResolver<CedarDouble> *resolver;
    __block UIWindow *window;
    __block NSURL *URL;
    __block UIViewController *presentingViewController;
    __block URLVerificationBlock verifyThatTheURLWasSentToApplication;
    __block NoArgBlock verifyThatDisplayDestinationIsEnabled;

    beforeEach(^{
        resolver = nice_fake_for([MPURLResolver class]);
        fakeProvider.fakeMPURLResolver = resolver;

        delegate = nice_fake_for(@protocol(MPAdDestinationDisplayAgentDelegate));
        presentingViewController = [[[UIViewController alloc] init] autorelease];
        delegate stub_method("viewControllerForPresentingModalView").and_return(presentingViewController);

        agent = [MPAdDestinationDisplayAgent agentWithDelegate:delegate];

        window = [[[UIWindow alloc] init] autorelease];
        [window makeKeyAndVisible];

        verifyThatTheURLWasSentToApplication = [^(NSURL *URL){
            window.subviews.lastObject should be_nil;
            delegate should have_received(@selector(displayAgentWillLeaveApplication));
            [[UIApplication sharedApplication] lastOpenedURL] should equal(URL);
        } copy];

        verifyThatDisplayDestinationIsEnabled = [^{
            [delegate reset_sent_messages];
            [agent displayDestinationForURL:[NSURL URLWithString:@"http://www.google.com/"]];
            delegate should have_received(@selector(displayAgentWillPresentModal));
        } copy];
    });

    afterEach(^{
        [window resignKeyWindow];
    });

    describe(@"when told to display the destination for a URL", ^{
        beforeEach(^{
            URL = [NSURL URLWithString:@"http://www.google.com"];
            [agent displayDestinationForURL:URL];
        });

        it(@"should bring up the loading indicator", ^{
            window.subviews.lastObject should be_instance_of([MPProgressOverlayView class]);
        });

        it(@"should tell its delegate that an displayAgentWillPresentModal", ^{
            delegate should have_received(@selector(displayAgentWillPresentModal));
        });

        it(@"should tell the resolver to resolve the URL", ^{
            resolver should have_received(@selector(startResolvingWithURL:delegate:)).with(URL).and_with(agent);
        });

        describe(@"when its told again (immediately)", ^{
            it(@"should ignore the second request", ^{
                [delegate reset_sent_messages];
                [agent displayDestinationForURL:URL];
                delegate should_not have_received(@selector(displayAgentWillPresentModal));
            });
        });
    });

    describe(@"when told to display a webview with an HTML string and a base URL", ^{
        __block MPAdBrowserController *browser;
        beforeEach(^{
            URL = [NSURL URLWithString:@"http://www.google.com"];
            [agent displayDestinationForURL:URL];
            [agent showWebViewWithHTMLString:@"Hello" baseURL:URL];

            presentingViewController.presentedViewController should be_instance_of([MPAdBrowserController class]);
            browser = (MPAdBrowserController *)presentingViewController.presentedViewController;

            browser.view should_not be_nil;
            [browser viewWillAppear:NO];
            [browser viewDidAppear:NO];
        });

        it(@"should hide the loading indicator", ^{
            window.subviews.lastObject should be_nil;
        });

        it(@"should present a correctly configured webview", ^{
            browser.URL should equal(URL);
            browser.webView.loadedHTMLString should equal(@"Hello");
        });

        context(@"when the browser is closed", ^{
            beforeEach(^{
                [browser.doneButton tap];
            });

            it(@"should tell its delegate that an displayAgentDidDismissModal", ^{
                delegate should have_received(@selector(displayAgentDidDismissModal));
            });

            it(@"should dismiss the browser modal", ^{
                presentingViewController.presentedViewController should be_nil;
            });

            it(@"should allow subsequent displayDestinationForURL: calls", ^{
                verifyThatDisplayDestinationIsEnabled();
            });
        });
    });

    describe(@"when told to ask the application to open the URL", ^{
        beforeEach(^{
            URL = [NSURL URLWithString:@"http://maps.google.com/timbuktu"];
            [agent displayDestinationForURL:URL];
            [agent openURLInApplication:URL];
        });

        it(@"should hide the loading indicator, tell the delegate, and send the URL to the shared application", ^{
            verifyThatTheURLWasSentToApplication(URL);
        });

        it(@"should allow subsequent displayDestinationForURL: calls", ^{
            verifyThatDisplayDestinationIsEnabled();
        });
    });

    describe(@"when told to show a store kit item", ^{
        beforeEach(^{
            URL = [NSURL URLWithString:@"http://itunes.apple.com/something/id1234"];
        });

        context(@"when store kit is available", ^{
            __block FakeStoreProductViewController *store;

            beforeEach(^{
                [MPStoreKitProvider setDeviceHasStoreKit:YES];
                [agent displayDestinationForURL:URL];
                [agent showStoreKitProductWithParameter:@"1234" fallbackURL:URL];
                store = [MPStoreKitProvider lastStore];
            });

            it(@"should tell store kit to load the store item and present the view controller", ^{
                store.storeItemIdentifier should equal(@"1234");
                window.subviews.lastObject should be_nil;
                presentingViewController.presentedViewController should equal(store);
            });

            context(@"when the person leaves the store", ^{
                beforeEach(^{
                    [store.delegate productViewControllerDidFinish:store];
                });

                it(@"should dismiss the store", ^{
                    presentingViewController.presentedViewController should be_nil;
                });

                it(@"should tell its delegate that an displayAgentDidDismissModal", ^{
                    delegate should have_received(@selector(displayAgentDidDismissModal));
                });

                it(@"should allow subsequent displayDestinationForURL: calls", ^{
                    verifyThatDisplayDestinationIsEnabled();
                });
            });
        });

        context(@"when store kit is not available (iOS < 6)", ^{
            beforeEach(^{
                [MPStoreKitProvider setDeviceHasStoreKit:NO];
                [agent displayDestinationForURL:URL];
                [agent showStoreKitProductWithParameter:@"1234" fallbackURL:URL];
            });

            it(@"should ask the application to load the URL", ^{
                verifyThatTheURLWasSentToApplication(URL);
            });
        });
    });

    describe(@"when the resolution of the URL fails", ^{
        beforeEach(^{
            URL = [NSURL URLWithString:@"floogbarg://dummy"];
            [agent displayDestinationForURL:URL];
            [agent failedToResolveURLWithError:nil];
        });

        it(@"should hide the loading indicator", ^{
            window.subviews.lastObject should be_nil;
        });

        it(@"should tell the delegate that an displayAgentDidDismissModal", ^{
            delegate should have_received(@selector(displayAgentDidDismissModal));
        });

        it(@"should allow subsequent displayDestinationForURL: calls", ^{
            verifyThatDisplayDestinationIsEnabled();
        });
    });

    describe(@"when the user cancels by closing the loading indicator", ^{
        beforeEach(^{
            URL = [NSURL URLWithString:@"http://www.google.com"];
            [agent displayDestinationForURL:URL];
            [agent overlayCancelButtonPressed];
        });

        it(@"should cancel the resolver", ^{
            resolver should have_received(@selector(cancel));
        });

        it(@"should tell the delegate that an displayAgentDidDismissModal", ^{
            delegate should have_received(@selector(displayAgentDidDismissModal));
        });

        it(@"should hide the overlay", ^{
            window.subviews.lastObject should be_nil;
        });

        it(@"should allow subsequent displayDestinationForURL: calls", ^{
            verifyThatDisplayDestinationIsEnabled();
        });
    });

    describe(@"verifying that the resolver and display agent play nice", ^{
        beforeEach(^{
            fakeProvider.fakeMPURLResolver = nil;
            agent = [MPAdDestinationDisplayAgent agentWithDelegate:delegate];
        });

        it(@"should use the resolver to determine what to do with the URL", ^{
            URL = [NSURL URLWithString:@"http://maps.google.com"];
            [agent displayDestinationForURL:URL];
            [[UIApplication sharedApplication] lastOpenedURL] should equal(URL);
        });
    });
});

SPEC_END
