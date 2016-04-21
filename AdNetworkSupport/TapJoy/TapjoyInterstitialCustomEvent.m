
#import "TapjoyInterstitialCustomEvent.h"
#import <Tapjoy/TJPlacement.h>
#import "MPLogging.h"

@interface TapjoyInterstitialCustomEvent () <TJPlacementDelegate>
@property (nonatomic, strong) TJPlacement *placement;
@end


@implementation TapjoyInterstitialCustomEvent

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Requesting Tapjoy interstitial");
    // Grab placement name defined in MoPub dashboard as custom event data
    NSString *name = info[@"name"];

    if(name) {
        _placement = [TJPlacement placementWithName:name mediationAgent:@"mopub" mediationId:nil delegate:self];
        _placement.adapterVersion = @"3.0";
        [_placement requestContent];
    }
    else {
        MPLogInfo(@"Invalid Tapjoy placement name specified");
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
    }
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    MPLogInfo(@"Tapjoy interstitial will be shown");
    [_placement showContentWithViewController:nil];
}

- (void)dealloc
{
    _placement.delegate = nil;
}

#pragma mark - TJPlacementtDelegate

- (void)requestDidSucceed:(TJPlacement *)placement {
    if (placement.isContentAvailable) {
        MPLogInfo(@"Tapjoy interstitial request successful");
        [self.delegate interstitialCustomEvent:self didLoadAd:nil];
    }
    else {
        MPLogInfo(@"No Tapjoy interstitials available");
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
    }
}

- (void)requestDidFail:(TJPlacement *)placement error:(NSError *)error {
    MPLogInfo(@"Tapjoy interstitial request failed");
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)contentDidAppear:(TJPlacement *)placement {
    MPLogInfo(@"Tapjoy interstitial did appear");
    [self.delegate interstitialCustomEventWillAppear:self];
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)contentDidDisappear:(TJPlacement *)placement {
    MPLogInfo(@"Tapjoy interstitial did disappear");
    [self.delegate interstitialCustomEventWillDisappear:self];
    [self.delegate interstitialCustomEventDidDisappear:self];
}

@end
