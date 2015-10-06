#import "MPStaticNativeAdRenderer.h"
#import "MPStaticNativeAdRendererSettings.h"
#import "MPNativeAdRendererConfiguration.h"
#import "MPMoPubNativeAdAdapter.h"
#import "MPNativeAdConstants.h"
#import "FakeNativeAdRenderingClass.h"
#import "MPNativeAdRendererImageHandler.h"
#import "MPNativeAdRenderingImageLoader.h"

#define kImpressionTrackerURLsKey   @"imptracker"
#define kDefaultActionURLKey        @"clk"
#define kClickTrackerURLKey         @"clktracker"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPStaticNativeAdRenderer()

@property (nonatomic) MPNativeAdRendererImageHandler *rendererImageHandler;

@end

SPEC_BEGIN(MPStaticNativeAdRendererSpec)

describe(@"MPStaticNativeAdRendererSpec", ^{
    __block MPStaticNativeAdRenderer *renderer;
    __block MPStaticNativeAdRendererSettings *settings;
    __block MPNativeAdRendererConfiguration *config;
    __block MPMoPubNativeAdAdapter *adapter;
    __block NSDictionary *adapterProperties;

    beforeEach(^{
        adapterProperties = @{kAdTitleKey : @"WUT",
                              kAdTextKey : @"WUT DaWG",
                              kAdIconImageKey : kMPSpecsTestImageURL,
                              kAdMainImageKey : kMPSpecsTestImageURL,
                              kAdCTATextKey : @"DO IT",
                              kAdDAAIconImageKey : @"MPDAAIcon",
                              kImpressionTrackerURLsKey: @[@"http://www.mopub.com/a", @"http://www.mopub.com/b"],
                              kClickTrackerURLKey : @"http://www.mopub.com/c",
                              kDefaultActionURLKey : @"http://www.mopub.com/d"
                              };

        adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:adapterProperties.mutableCopy];
        settings = [[MPStaticNativeAdRendererSettings alloc] init];
        settings.renderingViewClass = [UIView class];
    });

    context(@"retrieving a renderer configuration", ^{
        beforeEach(^{
            config = [MPStaticNativeAdRenderer rendererConfigurationWithRendererSettings:settings];
        });

        it(@"should support mopub, facebook, and inmobi custom events", ^{
            config.supportedCustomEvents should contain(@"MPMoPubNativeCustomEvent");
            config.supportedCustomEvents should contain(@"FacebookNativeCustomEvent");
            config.supportedCustomEvents should contain(@"InMobiNativeCustomEvent");
        });

        it(@"should store the renderer settings", ^{
            config.rendererSettings should equal(settings);
        });

        it(@"should set the renderer class to the static native ad renderer", ^{
            config.rendererClass should equal([MPStaticNativeAdRenderer class]);
        });

        xit(@"should attach a gesture recognizer to the daa icon image view", ^{

        });

        xit(@"should hide the daa icon image view if no daa icon image was given", ^{

        });

        xit(@"should show the daa icon image view if the daa icon was given", ^{

        });
    });

    context(@"retrieving a view", ^{
        context(@"when the adapter has incorrect property types", ^{
            beforeEach(^{
                NSDictionary *badAdapterProperties = @{kAdTitleKey : @2,
                                                       kImpressionTrackerURLsKey: @[@"http://www.mopub.com/a", @"http://www.mopub.com/b"],
                                                       kClickTrackerURLKey : @"http://www.mopub.com/c",
                                                       kDefaultActionURLKey : @"http://www.mopub.com/d"
                                                       };
                adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:[badAdapterProperties mutableCopy]];
                renderer = [[MPStaticNativeAdRenderer alloc] initWithRendererSettings:settings];
            });

            it(@"should return an error and a nil view", ^{
                NSError *error;
                [renderer retrieveViewWithAdapter:adapter error:&error] should be_nil;
                error should_not be_nil;
            });
        });

        context(@"when the adapter has valid properties", ^{
            __block NSError *error;
            __block UIView *renderedView;

            beforeEach(^{
                renderer = [[MPStaticNativeAdRenderer alloc] initWithRendererSettings:settings];
                renderedView = [renderer retrieveViewWithAdapter:adapter error:&error];
            });

            it(@"should make set the autoresizing mask to flexible width/height on the rendered view", ^{
                renderedView.autoresizingMask should equal(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
            });

            xit(@"should fill out the ad with the adapter properties", ^{

            });

            xit(@"should ask the ad view for its ui elements to fill out the native ad view (if the view implements their corresponding delegate methods)", ^{

            });

            context(@"star rating", ^{
                beforeEach(^{
                    settings = [[MPStaticNativeAdRendererSettings alloc] init];
                    settings.renderingViewClass = [FakeNativeAdRenderingClass class];
                    renderer = [[MPStaticNativeAdRenderer alloc] initWithRendererSettings:settings];
                    renderedView = [renderer retrieveViewWithAdapter:adapter error:&error];
                });

                context(@"when the ad doesn't contain a star rating", ^{
                    it(@"should not ask the ad view to layout the star rating", ^{
                        ((FakeNativeAdRenderingClass *)renderedView).didLayoutStarRating should be_falsy;
                    });
                });

                context(@"when the ad does contain a star rating", ^{
                    __block NSMutableDictionary *propertiesWithStarRating;
                    beforeEach(^{
                        ((FakeNativeAdRenderingClass *)renderedView).didLayoutStarRating = NO;

                        propertiesWithStarRating = [NSMutableDictionary dictionaryWithDictionary:adapterProperties];
                        // A quick hack to just get a star rating in there even though MoPub doesn't support it.
                        propertiesWithStarRating[kAdStarRatingKey] = @(3.3f);

                        adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:propertiesWithStarRating.mutableCopy];

                        renderedView = [renderer retrieveViewWithAdapter:adapter error:&error];
                    });

                    it(@"should layout the star rating if the ad implements layoutStarRating:", ^{
                        ((FakeNativeAdRenderingClass *)renderedView).didLayoutStarRating should be_truthy;
                    });

                    it(@"should not layout the star rating if the ad doesn't implement layoutStarRating:", ^{
                        ^{
                            // We use a UIView for the rendering class so this will crash if -layoutAdAssets is sent to the UIView.
                            settings = [[MPStaticNativeAdRendererSettings alloc] init];
                            settings.renderingViewClass = [UIView class];
                            renderer = [[MPStaticNativeAdRenderer alloc] initWithRendererSettings:settings];
                            renderedView = [renderer retrieveViewWithAdapter:adapter error:&error];
                        } should_not raise_exception;
                    });

                    it(@"should pass a valid star rating object if the star rating is a valid value", ^{
                        propertiesWithStarRating[kAdStarRatingKey] = @(4.5f);
                        adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:propertiesWithStarRating.mutableCopy];

                        renderedView = [renderer retrieveViewWithAdapter:adapter error:&error];

                        ((FakeNativeAdRenderingClass *)renderedView).lastStarRating.floatValue should equal(4.5f);
                    });

                    it(@"should pass a valid star rating object if the star rating is the minimum valid value", ^{
                        propertiesWithStarRating[kAdStarRatingKey] = @(0);
                        adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:propertiesWithStarRating.mutableCopy];

                        renderedView = [renderer retrieveViewWithAdapter:adapter error:&error];

                        ((FakeNativeAdRenderingClass *)renderedView).lastStarRating.floatValue should equal(0);
                    });

                    it(@"should pass a valid star rating object if the star rating is the maximum valid value", ^{
                        propertiesWithStarRating[kAdStarRatingKey] = @(5.0f);
                        adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:propertiesWithStarRating.mutableCopy];

                        renderedView = [renderer retrieveViewWithAdapter:adapter error:&error];

                        ((FakeNativeAdRenderingClass *)renderedView).lastStarRating.floatValue should equal(5.0f);
                    });

                    it(@"should not call layoutStarRating on the view if the rating isn't a number", ^{
                        propertiesWithStarRating[kAdStarRatingKey] = @"(lol)";
                        adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:propertiesWithStarRating.mutableCopy];

                        renderedView = [renderer retrieveViewWithAdapter:adapter error:&error];

                        ((FakeNativeAdRenderingClass *)renderedView).didLayoutStarRating should be_falsy;
                    });

                    it(@"should not call layoutStarRating on the view if the rating is greater than the max", ^{
                        propertiesWithStarRating[kAdStarRatingKey] = @(6.0f);
                        adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:propertiesWithStarRating.mutableCopy];

                        renderedView = [renderer retrieveViewWithAdapter:adapter error:&error];

                        ((FakeNativeAdRenderingClass *)renderedView).didLayoutStarRating should be_falsy;
                    });

                    it(@"should not call layoutStarRating on the view if the rating is less than the min", ^{
                        propertiesWithStarRating[kAdStarRatingKey] = @(-1.34f);
                        adapter = [[MPMoPubNativeAdAdapter alloc] initWithAdProperties:propertiesWithStarRating.mutableCopy];

                        renderedView = [renderer retrieveViewWithAdapter:adapter error:&error];

                        ((FakeNativeAdRenderingClass *)renderedView).didLayoutStarRating should be_falsy;
                    });
                });
            });

            context(@"laying out custom assets", ^{
                context(@"when the view doesn't implement -layoutCustomAssets:imageHandler:", ^{
                    beforeEach(^{
                        settings = [[MPStaticNativeAdRendererSettings alloc] init];
                        settings.renderingViewClass = [UIView class];
                        renderer = [[MPStaticNativeAdRenderer alloc] initWithRendererSettings:settings];
                        renderedView = [renderer retrieveViewWithAdapter:adapter error:&error];
                    });

                    it(@"should not layout custom assets when its ad view has been moved into a view hierarchy", ^{
                        spy_on(renderedView);
                        // We depend on mpnativead to put the rendered view inside an MPNativeView which will in turn tell the renderer its ad view
                        // was added to the view hierarchy. For now we'll just call the method that is called when the ad view is added to the hierarchy.
                        [renderer adViewWillMoveToSuperview:[UIView new]];
                        renderedView should_not have_received(@selector(layoutCustomAssetsWithProperties:imageLoader:));
                    });
                });

                context(@"when the view does implement layoutCustomAssets:imageHandler:", ^{
                    beforeEach(^{
                        settings = [[MPStaticNativeAdRendererSettings alloc] init];
                        settings.renderingViewClass = [FakeNativeAdRenderingClass class];
                        renderer = [[MPStaticNativeAdRenderer alloc] initWithRendererSettings:settings];
                        renderedView = [renderer retrieveViewWithAdapter:adapter error:&error];
                    });

                    it(@"should layout custom assets when its ad view has been moved into a view hierarchy", ^{
                        spy_on(renderedView);
                        // We depend on mpnativead to put the rendered view inside an MPNativeView which will in turn tell the renderer its ad view
                        // was added to the view hierarchy. For now we'll just call the method that is called when the ad view is added to the hierarchy.
                        [renderer adViewWillMoveToSuperview:[UIView new]];
                        renderedView should have_received(@selector(layoutCustomAssetsWithProperties:imageLoader:));
                    });
                });
            });

            context(@"loading images", ^{
                it(@"should not load any images in -retrieveViewWithAdapter", ^{
                    spy_on(renderer);
                    [renderer retrieveViewWithAdapter:adapter error:&error];
                    renderer should_not have_received(@selector(loadImageForURL:intoImageView:));
                });

                context(@"when the view doesn't implement -nativeIconImageView or -nativeMainImageView", ^{
                    beforeEach(^{
                        settings = [[MPStaticNativeAdRendererSettings alloc] init];
                        settings.renderingViewClass = [UIView class];
                        renderer = [[MPStaticNativeAdRenderer alloc] initWithRendererSettings:settings];
                        renderedView = [renderer retrieveViewWithAdapter:adapter error:&error];
                    });

                    it(@"should not load images when its ad view has been moved into a view hierarchy", ^{
                        spy_on(renderer);
                        // We depend on mpnativead to put the rendered view inside an MPNativeView which will in turn tell the renderer its ad view
                        // was added to the view hierarchy. For now we'll just call the method that is called when the ad view is added to the hierarchy.
                        [renderer adViewWillMoveToSuperview:[UIView new]];
                        renderer should_not have_received(@selector(loadImageForURL:intoImageView:));
                    });
                });

                fcontext(@"when the view does implement -nativeIconImageView or -nativeMainImageView", ^{
                    beforeEach(^{
                        settings = [[MPStaticNativeAdRendererSettings alloc] init];
                        settings.renderingViewClass = [FakeNativeAdRenderingClass class];
                        renderer = [[MPStaticNativeAdRenderer alloc] initWithRendererSettings:settings];
                        renderer.rendererImageHandler = nice_fake_for([MPNativeAdRendererImageHandler class]);
                        renderedView = [renderer retrieveViewWithAdapter:adapter error:&error];
                    });

                    it(@"should load images when its ad view has been moved into a view hierarchy", ^{
                        // We depend on mpnativead to put the rendered view inside an MPNativeView which will in turn tell the renderer its ad view
                        // was added to the view hierarchy. For now we'll just call the method that is called when the ad view is added to the hierarchy.
                        [renderer adViewWillMoveToSuperview:[UIView new]];
                        renderer.rendererImageHandler should have_received(@selector(loadImageForURL:intoImageView:));
                    });
                });
            });
        });
    });

});

SPEC_END
