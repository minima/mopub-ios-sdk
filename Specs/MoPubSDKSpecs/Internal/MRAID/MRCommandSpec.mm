#import "MRCommand.h"
#import "MRAdView.h"
#import "MRAdViewDisplayController.h"
#import "MPAdDestinationDisplayAgent.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MRAdView ()

@property (nonatomic, retain) MPAdDestinationDisplayAgent *destinationDisplayAgent;

@end

SPEC_BEGIN(MRCommandSpec)

describe(@"MRCommand", ^{
    xit(@"should have its mapping logic tested", ^{});
});

describe(@"MRExpandCommand", ^{
    __block MRExpandCommand *command;
    __block MRAdView *mrAdView;
    __block MRAdViewDisplayController<CedarDouble> *mrAdViewDisplayController;

    beforeEach(^{
        mrAdView = [[[MRAdView alloc] init] autorelease];
        mrAdViewDisplayController = nice_fake_for([MRAdViewDisplayController class]);
        mrAdView.displayController = mrAdViewDisplayController;
        command = [[[MRExpandCommand alloc] init] autorelease];
        command.view = mrAdView;
    });

    describe(@".execute", ^{
        __block BOOL result;

        beforeEach(^{
            result = [command execute];
        });

        it(@"calls view's displayController method correctly and returns true", ^{
            mrAdViewDisplayController should have_received(@selector(expandToFrame:withURL:useCustomClose:isModal:shouldLockOrientation:));
            result should be_truthy();
        });
    });
});

describe(@"MROpenCommand", ^{
    __block MROpenCommand *command;
    __block MRAdView *mrAdView;
    __block MPAdDestinationDisplayAgent<CedarDouble> *displayAgent;

    beforeEach(^{
        mrAdView = [[[MRAdView alloc] init] autorelease];
        displayAgent = nice_fake_for([MPAdDestinationDisplayAgent class]);
        mrAdView.destinationDisplayAgent = displayAgent;
        command = [[[MROpenCommand alloc] init] autorelease];
        command.view = mrAdView;
    });

    context(@"when executing a valid open url", ^{
        __block BOOL result;

        beforeEach(^{
            command.parameters = @{@"url":@"http://www.google.com"};
            result = [command execute];
        });

        it(@"should tell the agent to open the url with a valid NSURL", ^{
            displayAgent should have_received(@selector(displayDestinationForURL:));
            displayAgent should_not have_received(@selector(displayDestinationForURL:)).with(nil);
        });
    });

    context(@"when executing an open url with illegal characters", ^{
        __block BOOL result;

        beforeEach(^{
            command.parameters = @{@"url":@"http://www.google.com|||$$$++"};
            result = [command execute];
        });

        it(@"should properly encode the url and tell the agent to open the url with a valid NSURL", ^{
            displayAgent should have_received(@selector(displayDestinationForURL:));
            displayAgent should_not have_received(@selector(displayDestinationForURL:)).with(nil);
        });
    });
});

SPEC_END
