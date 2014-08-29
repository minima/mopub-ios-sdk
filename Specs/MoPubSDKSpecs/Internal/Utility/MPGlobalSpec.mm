#import "MPGlobal.h"
#import "UIView+MPSpecs.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPGlobalSpec)

describe(@"MPGlobal", ^{
    it(@"should test the full suite of functionality", PENDING);

    describe(@"MPTelephoneConfirmationController", ^{
        context(@"initialization", ^{
            it(@"should return nil for non telephone URLs", ^{
                [[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"http://www.zombo.com"] clickHandler:nil] should be_nil;
                [[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"twitter://idontknow"] clickHandler:nil] should be_nil;
            });

            it(@"should return nil for tel: and telPrompt: URLs with no number", ^{
                [[[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"tel:"] clickHandler:nil] autorelease] should be_nil;
                [[[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"telprompt:"] clickHandler:nil] autorelease] should be_nil;
            });

            it(@"should initialize for tel scheme URLs", ^{
                [[[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"tel://3439899999"] clickHandler:nil] autorelease] should_not be_nil;
                [[[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"tel:3439899999"] clickHandler:nil] autorelease] should_not be_nil;
            });

            it(@"should initialize for telprompt scheme URLs", ^{
                [[[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"telprompt://3439899999"] clickHandler:nil] autorelease] should_not be_nil;
                [[[MPTelephoneConfirmationController alloc] initWithURL:[NSURL URLWithString:@"telprompt:3439899999"] clickHandler:nil] autorelease] should_not be_nil;
            });
        });
    });

    describe(@"MPViewIsVisible", ^{
        __block UIWindow *applicationWindow;
        __block UIView *testView;

        beforeEach(^{
            spy_on([UIApplication sharedApplication]);
            spy_on([UIApplication sharedApplication].delegate);

            applicationWindow = [[[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)] autorelease];
            applicationWindow.hidden = NO;
            [UIApplication sharedApplication].delegate stub_method(@selector(window)).and_return(applicationWindow);

            testView = [[[UIView alloc] initWithFrame:CGRectMake(0, 49, 100, 100)] autorelease];
            testView.hidden = NO;
            [testView mp_viewIsVisible];
        });

        it(@"should not use the key window", ^{
            [UIApplication sharedApplication] should_not have_received(@selector(keyWindow));
        });

        it(@"should use the application window", ^{
            [UIApplication sharedApplication].delegate should have_received(@selector(window));
        });

        it(@"should return false when the view is hidden", ^{
            testView.hidden = YES;
            [applicationWindow addSubview:testView];
            [testView mp_viewIsVisible] should be_falsy;
        });

        it(@"should return false if the view is not in the application window's hierarchy", ^{
            // Make the testView intersect the application window.
            testView.frame = CGRectMake(0, 0, 4, 4);
            [testView mp_viewIsVisible] should be_falsy;
        });

        context(@"when the view is within the application window's hierarchy", ^{
            __block UIView *ancestor;

            beforeEach(^{
                ancestor = [[[UIView alloc] init] autorelease];
                ancestor.frame = CGRectMake(0, 0, 10, 10);
                [ancestor addSubview:testView];
                [applicationWindow addSubview:ancestor];
            });

            it(@"should return false if the view has a hidden ancestor", ^{
                // Make the testView intersect the application window.
                testView.frame = CGRectMake(0, 0, 4, 4);

                ancestor.hidden = YES;
                [ancestor addSubview:testView];
                [applicationWindow addSubview:ancestor];

                [testView mp_viewIsVisible] should be_falsy;
            });

            context(@"when the view has no hidden ancestors", ^{
                beforeEach(^{
                    ancestor.hidden = NO;
                });

                it(@"should return true if the application window intersects the view", ^{
                    testView.frame = CGRectMake(99, 99, 10, 10);
                    [testView mp_viewIsVisible] should be_truthy;
                });

                it(@"should return false if the view doesn't intersect the window", ^{
                    testView.frame = CGRectMake(101, 101, 10, 10);
                    [testView mp_viewIsVisible] should be_falsy;
                });
            });
        });
    });

    describe(@"MPViewIntersectsApplicationWindowWithPercent", ^{
        __block UIWindow *applicationWindow;
        __block UIView *testView;

        beforeEach(^{
            applicationWindow = [[[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)] autorelease];

            spy_on([UIApplication sharedApplication].delegate);
            [UIApplication sharedApplication].delegate stub_method(@selector(window)).and_return(applicationWindow);
        });

        context(@"Y-axis", ^{
            context(@"when a view's intersection area is greater than the percent required", ^{
                beforeEach(^{
                    testView = [[[UIView alloc] initWithFrame:CGRectMake(0, 49, 100, 100)] autorelease];
                    [applicationWindow addSubview:testView];
                });

                it(@"should return YES", ^{
                    [testView mp_viewIntersectsApplicationWindowWithPercent:0.5f] should equal(YES);
                });
            });

            context(@"when a view's intersection area is equal to the percent required", ^{
                beforeEach(^{
                    testView = [[[UIView alloc] initWithFrame:CGRectMake(0, 50, 100, 100)] autorelease];
                    [applicationWindow addSubview:testView];
                });

                it(@"should return YES", ^{
                    [testView mp_viewIntersectsApplicationWindowWithPercent:0.5f] should equal(YES);
                });
            });

            context(@"when a view's intersection area is less than the percent required", ^{
                beforeEach(^{
                    testView = [[[UIView alloc] initWithFrame:CGRectMake(0, 51, 100, 100)] autorelease];
                    [applicationWindow addSubview:testView];
                });

                it(@"should return NO", ^{
                    [testView mp_viewIntersectsApplicationWindowWithPercent:0.5f] should equal(NO);
                });
            });
        });

        context(@"X-axis", ^{
            context(@"when a view's intersection area is greater than the percent required", ^{
                beforeEach(^{
                    testView = [[[UIView alloc] initWithFrame:CGRectMake(49, 0, 100, 100)] autorelease];
                    [applicationWindow addSubview:testView];
                });

                it(@"should return YES", ^{
                    [testView mp_viewIntersectsApplicationWindowWithPercent:0.5f] should equal(YES);
                });
            });

            context(@"when a view's intersection area is equal to the percent required", ^{
                beforeEach(^{
                    testView = [[[UIView alloc] initWithFrame:CGRectMake(50, 0, 100, 100)] autorelease];
                    [applicationWindow addSubview:testView];
                });

                it(@"should return YES", ^{
                    [testView mp_viewIntersectsApplicationWindowWithPercent:0.5f] should equal(YES);
                });
            });

            context(@"when a view's intersection area is less than the percent required", ^{
                beforeEach(^{
                    testView = [[[UIView alloc] initWithFrame:CGRectMake(51, 0, 100, 100)] autorelease];
                    [applicationWindow addSubview:testView];
                });

                it(@"should return NO", ^{
                    [testView mp_viewIntersectsApplicationWindowWithPercent:0.5f] should equal(NO);
                });
            });
        });

        context(@"Both axes", ^{
            context(@"when a view's intersection area is greater than the percent required", ^{
                beforeEach(^{
                    testView = [[[UIView alloc] initWithFrame:CGRectMake(29, 29, 100, 100)] autorelease];
                    [applicationWindow addSubview:testView];
                });

                it(@"should return YES", ^{
                    [testView mp_viewIntersectsApplicationWindowWithPercent:0.5f] should equal(YES);
                });
            });

            context(@"when a view's intersection area is less than the percent required", ^{
                beforeEach(^{
                    testView = [[[UIView alloc] initWithFrame:CGRectMake(30, 30, 100, 100)] autorelease];
                    [applicationWindow addSubview:testView];
                });

                it(@"should return NO", ^{
                    [testView mp_viewIntersectsApplicationWindowWithPercent:0.5f] should equal(NO);
                });
            });
        });

        context(@"Moving the same view around", ^{
            beforeEach(^{
                testView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
                [applicationWindow addSubview:testView];
            });

            it(@"should return the correct result", ^{
                testView.frame = CGRectMake(29, 29, 100, 100);
                [testView mp_viewIntersectsApplicationWindowWithPercent:0.5f] should equal(YES);

                testView.frame = CGRectMake(30, 30, 100, 100);
                [testView mp_viewIntersectsApplicationWindowWithPercent:0.5f] should equal(NO);
            });
        });
    });

    describe(@"MPViewIntersectsKeyWindowWithPercent", ^{
        __block UIWindow *keyWindow;
        __block UIView *testView;

        beforeEach(^{
            keyWindow = [[[UIWindow alloc] initWithFrame:CGRectMake(0, 0, 100, 100)] autorelease];
            [keyWindow makeKeyAndVisible];
        });

        context(@"Y-axis", ^{
            context(@"when a view's intersection area is greater than the percent required", ^{
                beforeEach(^{
                    testView = [[[UIView alloc] initWithFrame:CGRectMake(0, 49, 100, 100)] autorelease];
                    [keyWindow addSubview:testView];
                });

                it(@"should return YES", ^{
                    [testView mp_viewIntersectsKeyWindowWithPercent:0.5f] should equal(YES);
                });
            });

            context(@"when a view's intersection area is equal to the percent required", ^{
                beforeEach(^{
                    testView = [[[UIView alloc] initWithFrame:CGRectMake(0, 50, 100, 100)] autorelease];
                    [keyWindow addSubview:testView];
                });

                it(@"should return YES", ^{
                    [testView mp_viewIntersectsKeyWindowWithPercent:0.5f] should equal(YES);
                });
            });

            context(@"when a view's intersection area is less than the percent required", ^{
                beforeEach(^{
                    testView = [[[UIView alloc] initWithFrame:CGRectMake(0, 51, 100, 100)] autorelease];
                    [keyWindow addSubview:testView];
                });

                it(@"should return NO", ^{
                    [testView mp_viewIntersectsKeyWindowWithPercent:0.5f] should equal(NO);
                });
            });
        });

        context(@"X-axis", ^{
            context(@"when a view's intersection area is greater than the percent required", ^{
                beforeEach(^{
                    testView = [[[UIView alloc] initWithFrame:CGRectMake(49, 0, 100, 100)] autorelease];
                    [keyWindow addSubview:testView];
                });

                it(@"should return YES", ^{
                    [testView mp_viewIntersectsKeyWindowWithPercent:0.5f] should equal(YES);
                });
            });

            context(@"when a view's intersection area is equal to the percent required", ^{
                beforeEach(^{
                    testView = [[[UIView alloc] initWithFrame:CGRectMake(50, 0, 100, 100)] autorelease];
                    [keyWindow addSubview:testView];
                });

                it(@"should return YES", ^{
                    [testView mp_viewIntersectsKeyWindowWithPercent:0.5f] should equal(YES);
                });
            });

            context(@"when a view's intersection area is less than the percent required", ^{
                beforeEach(^{
                    testView = [[[UIView alloc] initWithFrame:CGRectMake(51, 0, 100, 100)] autorelease];
                    [keyWindow addSubview:testView];
                });

                it(@"should return NO", ^{
                    [testView mp_viewIntersectsKeyWindowWithPercent:0.5f] should equal(NO);
                });
            });
        });

        context(@"Both axes", ^{
            context(@"when a view's intersection area is greater than the percent required", ^{
                beforeEach(^{
                    testView = [[[UIView alloc] initWithFrame:CGRectMake(29, 29, 100, 100)] autorelease];
                    [keyWindow addSubview:testView];
                });

                it(@"should return YES", ^{
                    [testView mp_viewIntersectsKeyWindowWithPercent:0.5f] should equal(YES);
                });
            });

            context(@"when a view's intersection area is less than the percent required", ^{
                beforeEach(^{
                    testView = [[[UIView alloc] initWithFrame:CGRectMake(30, 30, 100, 100)] autorelease];
                    [keyWindow addSubview:testView];
                });

                it(@"should return NO", ^{
                    [testView mp_viewIntersectsKeyWindowWithPercent:0.5f] should equal(NO);
                });
            });
        });

        context(@"Moving the same view around", ^{
            beforeEach(^{
                testView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
                [keyWindow addSubview:testView];
            });

            it(@"should return the correct result", ^{
                testView.frame = CGRectMake(29, 29, 100, 100);
                [testView mp_viewIntersectsKeyWindowWithPercent:0.5f] should equal(YES);

                testView.frame = CGRectMake(30, 30, 100, 100);
                [testView mp_viewIntersectsKeyWindowWithPercent:0.5f] should equal(NO);
            });
        });
    });
});

SPEC_END
