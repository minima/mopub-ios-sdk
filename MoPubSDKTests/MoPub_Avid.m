//
//  MoPub_Avid.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MoPub_Avid.h"

@implementation MoPub_AvidDeferredAdSessionListener

- (void)recordReadyEvent {
}

@end

@implementation MoPub_AbstractAvidAdSession

- (void)endSession {
}

- (void)registerAdView:(UIView *)view {
}

- (void)registerFriendlyObstruction:(UIView *)view {
}

@end

@implementation MoPub_ExternalAvidAdSessionContext

+ (MoPub_ExternalAvidAdSessionContext *)contextWithPartnerVersion:(NSString *)version isDeferred:(BOOL)isDeferred {
    return MoPub_ExternalAvidAdSessionContext.new;
}

@end

@implementation MoPub_AvidAdSessionManager

+ (MoPub_AbstractAvidAdSession *)startAvidDisplayAdSessionWithContext:(MoPub_ExternalAvidAdSessionContext *)context {
    return MoPub_AbstractAvidAdSession.new;
}

+ (MoPub_AbstractAvidAdSession *)startAvidVideoAdSessionWithContext:(MoPub_ExternalAvidAdSessionContext *)context {
    return MoPub_AbstractAvidAdSession.new;
}

@end
