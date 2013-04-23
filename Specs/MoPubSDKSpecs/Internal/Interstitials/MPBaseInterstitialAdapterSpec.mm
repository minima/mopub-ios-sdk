#import "MPBaseInterstitialAdapter.h"

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
        context(@"when beginning a request", ^{
            beforeEach(^{
                [adapter _getAdWithConfiguration:nil];
            });

            it(@"should timeout and tell the delegate about the failure after 10 seconds", ^{
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
                    [fakeProvider advanceMPTimers:1];
                    delegate should_not have_received(@selector(adapter:didFailToLoadAdWithError:));
                });
            });
        });
    });
});

SPEC_END
