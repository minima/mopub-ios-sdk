#import "MRCommand.h"
#import "MRAdView.h"
#import "MRAdViewDisplayController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

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

SPEC_END
