//
//  MPMockNativeCustomEvent.m
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import "MPMockNativeCustomEvent.h"
#import "MPNativeAd.h"

@interface MPMockNativeCustomEvent()
@property (nonatomic, strong) MPNativeAd * nativeAd;
@end

@implementation MPMockNativeCustomEvent

- (instancetype)init {
    if (self = [super init]) {
        _nativeAd = [[MPNativeAd alloc] initWithAdAdapter:nil];
    }

    return self;
}

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(nativeCustomEvent:didLoadAd:)]) {
            [self.delegate nativeCustomEvent:self didLoadAd:self.nativeAd];
        }
    });
}

@end

@implementation MPMockNativeCustomEventView

- (UILabel *)nativeMainTextLabel
{
    return self.mainTextLabel;
}

- (UILabel *)nativeTitleTextLabel
{
    return self.titleLabel;
}

- (UILabel *)nativeCallToActionTextLabel
{
    return self.callToActionLabel;
}

- (UIImageView *)nativeIconImageView
{
    return self.iconImageView;
}

- (UIImageView *)nativeMainImageView
{
    return self.mainImageView;
}

- (UIImageView *)nativePrivacyInformationIconImageView
{
    return self.privacyInformationIconImageView;
}

@end
