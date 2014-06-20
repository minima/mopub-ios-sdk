#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "FacebookNativeAdAdapter.h"
#import "MPNativeAdConstants.h"
#import "FBNativeAd+Specs.h"
#import "MPNativeAd.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FacebookNativeAdAdapterSpec)

describe(@"FacebookNativeAdAdapter", ^{
    context(@"when initializing", ^{
        __block FBNativeAd<CedarDouble> *mockFBAd;
        __block FacebookNativeAdAdapter *adAdapter;

        beforeEach(^{
            mockFBAd = nice_fake_for([FBNativeAd class]);
            adAdapter = [[[FacebookNativeAdAdapter alloc] initWithFBNativeAd:mockFBAd] autorelease];
            [FBNativeAd useZeroScaleInStarRating:NO];
        });

        it(@"should not crash if any property is nil", ^{
            ^{
                FacebookNativeAdAdapter *testAd = [[[FacebookNativeAdAdapter alloc] initWithFBNativeAd:mockFBAd] autorelease];
                (void)testAd;  // Make Xcode think we're using the testAd so it'll compile.
            } should_not raise_exception;
        });

        it(@"should not crash with a 0 scale in star rating", ^{
            ^{
                [FBNativeAd useZeroScaleInStarRating:YES];

                FBNativeAd *nativeAd = [[[FBNativeAd alloc] initWithPlacementID:@"399393939"] autorelease];
                FacebookNativeAdAdapter *testAd = [[[FacebookNativeAdAdapter alloc] initWithFBNativeAd:nativeAd] autorelease];

                (void)testAd;
            } should_not raise_exception;
        });

        it(@"should map its properties correctly", ^{
            FBNativeAd<CedarDouble> *mockPropertiesAd = nice_fake_for([FBNativeAd class]);
            mockPropertiesAd stub_method(@selector(coverImage)).and_return([[[FBAdImage alloc] initWithURL:[NSURL URLWithString:@"https://pbs.twimg.com/profile_images/431949550836662272/A6Ck-0Gx_normal.png"] width:50 height:50] autorelease]);
            mockPropertiesAd stub_method(@selector(icon)).and_return([[[FBAdImage alloc] initWithURL:[NSURL URLWithString:@"https://pbs.twimg.com/profile_images/431949550836662272/A6Ck-0Gx_normal.png"] width:50 height:50] autorelease]);
            mockPropertiesAd stub_method(@selector(title)).and_return(@"title");
            mockPropertiesAd stub_method(@selector(body)).and_return(@"text");
            mockPropertiesAd stub_method(@selector(callToAction)).and_return(@"cta");

            FacebookNativeAdAdapter *testAd = [[[FacebookNativeAdAdapter alloc] initWithFBNativeAd:mockPropertiesAd] autorelease];
            NSDictionary *properties = testAd.properties;

            [properties objectForKey:kAdTitleKey] should equal(@"title");
            [properties objectForKey:kAdTextKey] should equal(@"text");
            [properties objectForKey:kAdIconImageKey] should equal(@"https://pbs.twimg.com/profile_images/431949550836662272/A6Ck-0Gx_normal.png");
            [properties objectForKey:kAdMainImageKey] should equal(@"https://pbs.twimg.com/profile_images/431949550836662272/A6Ck-0Gx_normal.png");
            [properties objectForKey:kAdCTATextKey] should equal(@"cta");
        });

        it(@"should calculate star rating correctly", ^{
            // It doesn't look like we can return a struct in a stubbed method, so we'll use the FBNativeAd+Spec class to allow us to test that.
            FBNativeAd *nativeAd = [[[FBNativeAd alloc] initWithPlacementID:@"399393939"] autorelease];
            FacebookNativeAdAdapter *testAd = [[[FacebookNativeAdAdapter alloc] initWithFBNativeAd:nativeAd] autorelease];

            struct FBAdStarRating starRating = nativeAd.starRating;

            CGFloat ratio = 1.0f;

            if (starRating.scale != 0) {
                ratio = kUniversalStarRatingScale/starRating.scale;
                [NSNumber numberWithFloat:ratio*starRating.value] should equal([testAd.properties objectForKey:kAdStarRatingKey]);
            }
        });

        it(@"should give nil for star rating if fb star rating gives 0 for scale", ^{
            [FBNativeAd useZeroScaleInStarRating:YES];

            FBNativeAd *nativeAd = [[[FBNativeAd alloc] initWithPlacementID:@"399393939"] autorelease];
            FacebookNativeAdAdapter *testAd = [[[FacebookNativeAdAdapter alloc] initWithFBNativeAd:nativeAd] autorelease];

            [testAd.properties objectForKey:kAdStarRatingKey] should be_nil;
        });

        it(@"should have 0.0 for requiredSecondsForImpression", ^{
            adAdapter.requiredSecondsForImpression should equal(0.0);
        });

        it(@"should have a nil defaultActionURL", ^{
            adAdapter.defaultActionURL should be_nil;
        });

        it(@"should call the fbNativeAd's log impression when trackImpression is called", ^{
            [adAdapter trackImpression];
            mockFBAd should have_received(@selector(logImpression));
        });

        it(@"should call fbNativeAd's handleClick method when displayContentForURL is called", ^{
            [adAdapter displayContentForURL:nil rootViewController:[[[UIViewController alloc] init] autorelease] completion:nil];
            mockFBAd should have_received(@selector(handleClickWithViewController:callback:));
        });

        it(@"should return an error in the completion block when calling displayContentURL with a nil rootViewController", ^{
            __block BOOL returnedError = NO;
            [adAdapter displayContentForURL:[NSURL URLWithString:@"http://www.mopub.com"] rootViewController:nil completion:^(BOOL success, NSError *error) {
                returnedError = !success;
            }];

            returnedError should be_truthy;
        });
    });
});

SPEC_END
