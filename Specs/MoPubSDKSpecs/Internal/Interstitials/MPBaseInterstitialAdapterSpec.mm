#import "MPBaseInterstitialAdapter.h"
#import "MPConstants.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface ConcreteInterstitialAdapter : MPBaseInterstitialAdapter

- (void)simulateLoadingFinished;

@end

@implementation ConcreteInterstitialAdapter

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration
{
}

- (void)simulateLoadingFinished
{
    [self didStopLoading];
}

@end


SPEC_BEGIN(MPBaseInterstitialAdapterSpec)

describe(@"MPBaseInterstitialAdapter", ^{
    __block ConcreteInterstitialAdapter *adapter;
    __block id<CedarDouble, MPInterstitialAdapterDelegate> delegate;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPInterstitialAdapterDelegate));
        adapter = [[[ConcreteInterstitialAdapter alloc] initWithDelegate:delegate] autorelease];
    });

    describe(@"timing out requests", ^{
        context(@"when beginning a request with no configured timeout", ^{
            beforeEach(^{
                [adapter _getAdWithConfiguration:nil];
            });

            it(@"should not timeout before the default timeout interval", ^{
                [fakeProvider advanceMPTimers:29];
                delegate should_not have_received(@selector(adapter:didFailToLoadAdWithError:));
            });

            it(@"should timeout and tell the delegate using the default timeout interval", ^{
                [fakeProvider advanceMPTimers:30];
                delegate should have_received(@selector(adapter:didFailToLoadAdWithError:));
            });

            context(@"when the request finishes before the timeout", ^{
                beforeEach(^{
                    [fakeProvider advanceMPTimers:29];
                    [adapter simulateLoadingFinished];
                });

                it(@"should not, later, fire the timeout", ^{
                    [delegate reset_sent_messages];
                    // due to implementation detail of fake MPTimer advanceTime, only 1 'tick' is required here
                    [fakeProvider advanceMPTimers:1];
                    delegate should_not have_received(@selector(adapter:didFailToLoadAdWithError:));
                });
            });
        });

        context(@"when beginning a request with a 60 second configured timeout", ^{
            __block NSDictionary *headers;
            __block MPAdConfiguration *configuration;

            beforeEach(^{
                headers = @{kAdTimeoutHeaderKey: @"60"};
                configuration = [[[MPAdConfiguration alloc] initWithHeaders:headers data:nil] autorelease];
                [adapter _getAdWithConfiguration:configuration];
            });

            it(@"should not timeout before the configurable value", ^{
                [fakeProvider advanceMPTimers:59];
                delegate should_not have_received(@selector(adapter:didFailToLoadAdWithError:));
            });

            it(@"should timeout and tell the delegate after 60 seconds", ^{
                [fakeProvider advanceMPTimers:60];
                delegate should have_received(@selector(adapter:didFailToLoadAdWithError:));
            });

            // NOTE: Not testing "when the request finishes" here since that behavior will always be the same
            //       regardless of what timeout value is set
        });

        context(@"when beginning a request with a 1 second configured timeout", ^{
            __block NSDictionary *headers;
            __block MPAdConfiguration *configuration;

            beforeEach(^{
                headers = @{kAdTimeoutHeaderKey: @"1"};
                configuration = [[[MPAdConfiguration alloc] initWithHeaders:headers data:nil] autorelease];
                [adapter _getAdWithConfiguration:configuration];
            });

            it(@"should not timeout before the configurable value", ^{
                [fakeProvider advanceMPTimers:0];
                delegate should_not have_received(@selector(adapter:didFailToLoadAdWithError:));
            });

            it(@"should timeout and tell the delegate after 1 second", ^{
                [fakeProvider advanceMPTimers:1];
                delegate should have_received(@selector(adapter:didFailToLoadAdWithError:));
            });
        });

        context(@"when beginning a request with a 0 second configured timeout", ^{
            __block NSDictionary *headers;
            __block MPAdConfiguration *configuration;

            beforeEach(^{
                headers = @{kAdTimeoutHeaderKey: @"0"};
                configuration = [[[MPAdConfiguration alloc] initWithHeaders:headers data:nil] autorelease];
                [adapter _getAdWithConfiguration:configuration];
            });

            it(@"should never time out", ^{
                // should technically wait forever, not passing MAX val here since the impl of
                // fakeProvider's fake timer does involve a loop and would slow the test too much
                [fakeProvider advanceMPTimers:999999];
                delegate should_not have_received(@selector(adapter:didFailToLoadAdWithError:));
            });
        });

        context(@"when beginning a request with an configured timeout that is a negative value", ^{
            __block NSDictionary *headers;
            __block MPAdConfiguration *configuration;

            beforeEach(^{
                headers = @{kAdTimeoutHeaderKey: @"-1"};
                configuration = [[[MPAdConfiguration alloc] initWithHeaders:headers data:nil] autorelease];
                [adapter _getAdWithConfiguration:configuration];
            });

            it(@"should not timeout before the default timeout interval", ^{
                [fakeProvider advanceMPTimers:INTERSTITIAL_TIMEOUT_INTERVAL - 1];
                delegate should_not have_received(@selector(adapter:didFailToLoadAdWithError:));
            });

            it(@"should timeout and tell the delegate using the default timeout interval", ^{
                [fakeProvider advanceMPTimers:INTERSTITIAL_TIMEOUT_INTERVAL];
                delegate should have_received(@selector(adapter:didFailToLoadAdWithError:));
            });
        });
    });
});

SPEC_END
