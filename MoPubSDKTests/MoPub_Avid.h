//
//  MoPub_Avid.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// These are a collection of mock IAS objects to stub out the viewability
/// functionality for unit testing.

@interface MoPub_AvidDeferredAdSessionListener : NSObject
- (void)recordReadyEvent;
@end

@interface MoPub_AbstractAvidAdSession : NSObject
@property (nonatomic, strong) MoPub_AvidDeferredAdSessionListener * avidDeferredAdSessionListener;
- (void)endSession;
- (void)registerAdView:(UIView *)view;
- (void)registerFriendlyObstruction:(UIView *)view;
@end

@interface MoPub_ExternalAvidAdSessionContext : NSObject
+ (MoPub_ExternalAvidAdSessionContext *)contextWithPartnerVersion:(NSString *)version isDeferred:(BOOL)isDeferred;
@end

@interface MoPub_AvidAdSessionManager : NSObject
+ (MoPub_AbstractAvidAdSession *)startAvidDisplayAdSessionWithContext:(MoPub_ExternalAvidAdSessionContext *)context;
+ (MoPub_AbstractAvidAdSession *)startAvidVideoAdSessionWithContext:(MoPub_ExternalAvidAdSessionContext *)context;

@end
