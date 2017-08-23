//
//  MPViewabilityTracker.m
//  MoPubSDK
//
//  Copyright © 2016 MoPub. All rights reserved.
//

#import "MoPub.h"
#import "MPLogging.h"
#import "MPViewabilityTracker.h"
#import "MPWebView+Viewability.h"

#if __has_include(<MPUBMoatMobileAppKit/MPUBMoatMobileAppKit.h>)
#import <MPUBMoatMobileAppKit/MPUBMoatMobileAppKit.h>
#define __HAS_MOAT_FRAMEWORK_
#endif

#if __has_include("MoPub_Avid.h")
#import "MoPub_Avid.h"
#define __HAS_AVID_LIB_
#endif

#ifdef __HAS_MOAT_FRAMEWORK_
static NSString *const kMOATSendAdStoppedJavascript = @"MoTracker.sendMoatAdStoppedEvent()";
#endif

static MPViewabilityOption sEnabledViewabilityVendors = 0;
NSString *const kDisableViewabilityTrackerNotification = @"com.mopub.mopub-ios-sdk.viewability.disabletracking";
NSString *const kDisabledViewabilityTrackers = @"disableViewabilityTrackers";

@interface MPViewabilityTracker()
#ifdef __HAS_AVID_LIB_
@property (nonatomic, strong) MoPub_AbstractAvidAdSession * avidAdSession;
#endif

#ifdef __HAS_MOAT_FRAMEWORK_
@property (nonatomic, strong) MPUBMoatWebTracker * moatWebTracker;
@property (nonatomic, strong) MPWebView *webView;
@property (nonatomic, assign) BOOL isVideo;
#endif

@property (nonatomic, assign) MPViewabilityOption trackersInProgress;
@end

@implementation MPViewabilityTracker
 
+ (void)initialize {
    if (self == [MPViewabilityTracker class]) {
        #ifdef __HAS_MOAT_FRAMEWORK_
        sEnabledViewabilityVendors |= MPViewabilityOptionMoat;
        MPLogInfo(@"[Viewability] MOAT SDK was found.");
        #endif
        
        #ifdef __HAS_AVID_LIB_
        sEnabledViewabilityVendors |= MPViewabilityOptionIAS;
        MPLogInfo(@"[Viewability] IAS SDK was found.");
        #endif
    }
}

- (instancetype)initWithAdView:(MPWebView *)webView
                       isVideo:(BOOL)isVideo
      startTrackingImmediately:(BOOL)startTracking {
    if (self = [super init]) {
        // Initially not tracking.
        _trackersInProgress = MPViewabilityOptionNone;
        
        // While the viewability SDKs have features that allow the developer to pass in a container view, WKWebView is
        // not always in MPWebView's view hierarchy. Pass in the contained web view to be safe, as we don't know for
        // sure *how* or *when* MPWebView is traversed.
        UIView *view = webView.containedWebView;
        
        // Invalid ad view
        if (view == nil) {
            MPLogError(@"nil ad view passed into %s", __PRETTY_FUNCTION__);
            
            #ifdef __HAS_AVID_LIB_
            _avidAdSession = nil;
            #endif
            
            #ifdef __HAS_MOAT_FRAMEWORK_
            _moatWebTracker = nil;
            #endif
            
            return nil;
        }
        
        // Register handler for disabling of viewability tracking.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDisableViewabilityTrackingForNotification:) name:kDisableViewabilityTrackerNotification object:nil];
        
        #ifdef __HAS_MOAT_FRAMEWORK_
        if ((sEnabledViewabilityVendors & MPViewabilityOptionMoat) == MPViewabilityOptionMoat) {
            static dispatch_once_t sMoatSharedInstanceStarted;
            dispatch_once(&sMoatSharedInstanceStarted, ^{
                // explicitly disable location tracking and IDFA tracking
                MPUBMoatOptions *options = [[MPUBMoatOptions alloc] init];
                options.locationServicesEnabled = NO;
                options.IDFACollectionEnabled = NO;
                options.debugLoggingEnabled = NO;
                
                // start with options
                [[MPUBMoatAnalytics sharedInstance] startWithOptions:options];
            });
            
            _moatWebTracker = [MPUBMoatWebTracker trackerWithWebComponent:view];
            _webView = webView;
            _isVideo = isVideo;
            if (_moatWebTracker == nil) {
                NSString * adViewClassName = NSStringFromClass([view class]);
                MPLogError(@"Couldn't attach Moat to %@.", adViewClassName);
            }
            
            if (startTracking) {
                [_moatWebTracker startTracking];
                _trackersInProgress |= MPViewabilityOptionMoat;
                MPLogInfo(@"[Viewability] MOAT tracking started");
            }
        }
        else {
            _moatWebTracker = nil;
        }
        #endif
        
        #ifdef __HAS_AVID_LIB_
        if ((sEnabledViewabilityVendors & MPViewabilityOptionIAS) == MPViewabilityOptionIAS) {
            MoPub_ExternalAvidAdSessionContext * avidAdSessionContext = [MoPub_ExternalAvidAdSessionContext contextWithPartnerVersion:[[MoPub sharedInstance] version] isDeferred:!startTracking];
            if (isVideo) {
                _avidAdSession = [MoPub_AvidAdSessionManager startAvidVideoAdSessionWithContext:avidAdSessionContext];
            }
            else {
                _avidAdSession = [MoPub_AvidAdSessionManager startAvidDisplayAdSessionWithContext:avidAdSessionContext];
            }
            [_avidAdSession registerAdView:view];
            
            if (startTracking) {
                _trackersInProgress |= MPViewabilityOptionIAS;
                MPLogInfo(@"[Viewability] IAS tracking started");
            }
        }
        else {
            _avidAdSession = nil;
        }
        #endif
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopTracking];
}

- (void)startTracking {
    [self startTrackingIAS];
    [self startTrackingMoat];
}

- (void)stopTracking:(MPViewabilityOption)vendors {
    // Stop IAS tracking
    if ((vendors & MPViewabilityOptionIAS) == MPViewabilityOptionIAS) {
        [self stopTrackingIAS];
    }
    
    // Stop Moat tracking
    if ((vendors & MPViewabilityOptionMoat) == MPViewabilityOptionMoat) {
        [self stopTrackingMoat];
    }
}

- (void)stopTracking {
    [self stopTracking:(MPViewabilityOptionMoat | MPViewabilityOptionIAS)];
}

- (void)registerFriendlyObstructionView:(UIView *)view {
#ifdef __HAS_AVID_LIB_
    [self.avidAdSession registerFriendlyObstruction:view];
#endif
}

+ (MPViewabilityOption)enabledViewabilityVendors {
    return sEnabledViewabilityVendors;
}

+ (void)disableViewability:(MPViewabilityOption)vendors {
    // Keep around the old viewability bitmask for comparing if the
    // state has changed.
    MPViewabilityOption oldEnabledVendors = sEnabledViewabilityVendors;
    
    // Disable IAS
    if ((vendors & MPViewabilityOptionIAS) == MPViewabilityOptionIAS) {
        sEnabledViewabilityVendors &= ~MPViewabilityOptionIAS;
    }
    // Disable Moat
    if ((vendors & MPViewabilityOptionMoat) == MPViewabilityOptionMoat) {
        sEnabledViewabilityVendors &= ~MPViewabilityOptionMoat;
    }
    
    // Broadcast that some viewability tracking has been disabled.
    if (vendors != MPViewabilityOptionNone && oldEnabledVendors != sEnabledViewabilityVendors) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDisableViewabilityTrackerNotification object:nil userInfo:@{kDisabledViewabilityTrackers: @(vendors)}];
    }
}

#pragma mark - Notification Handlers

- (void)onDisableViewabilityTrackingForNotification:(NSNotification *)notification {
    MPViewabilityOption disabledTrackers = MPViewabilityOptionNone;
    if (notification.userInfo != nil && [notification.userInfo objectForKey:kDisabledViewabilityTrackers] != nil) {
        disabledTrackers = (MPViewabilityOption)[[notification.userInfo objectForKey:kDisabledViewabilityTrackers] integerValue];
    }
    
    // Immediately stop all tracking for the disabled viewability vendors.
    [self stopTracking:disabledTrackers];
}

#pragma mark - IAS

- (void)startTrackingIAS {
    // Only start tracking if:
    // 1. IAS is enabled
    // 2. IAS is not already tracking
    if ((sEnabledViewabilityVendors & MPViewabilityOptionIAS) == MPViewabilityOptionIAS && (self.trackersInProgress & MPViewabilityOptionIAS) != MPViewabilityOptionIAS) {
#ifdef __HAS_AVID_LIB_
        if (self.avidAdSession != nil && (sEnabledViewabilityVendors & MPViewabilityOptionIAS) == MPViewabilityOptionIAS) {
            [self.avidAdSession.avidDeferredAdSessionListener recordReadyEvent];
            self.trackersInProgress |= MPViewabilityOptionIAS;
            MPLogInfo(@"[Viewability] IAS tracking started");
        }
#endif
    }
}

- (void)stopTrackingIAS {
    // Only stop tracking if:
    // 1. IAS is already tracking
    if ((self.trackersInProgress & MPViewabilityOptionIAS) != MPViewabilityOptionIAS) {
#ifdef __HAS_AVID_LIB_
        [self.avidAdSession endSession];
        if (self.avidAdSession) {
            MPLogInfo(@"[Viewability] IAS tracking stopped");
        }
#endif
    }
    
    // Mark IAS as not tracking
    self.trackersInProgress &= ~MPViewabilityOptionIAS;
}

#pragma mark - Moat

- (void)startTrackingMoat {
    // Only start tracking if:
    // 1. Moat is enabled
    // 2. Moat is not already tracking
    if ((sEnabledViewabilityVendors & MPViewabilityOptionMoat) == MPViewabilityOptionMoat && (self.trackersInProgress & MPViewabilityOptionMoat) != MPViewabilityOptionMoat) {
#ifdef __HAS_MOAT_FRAMEWORK_
        if (self.moatWebTracker != nil) {
            [self.moatWebTracker startTracking];
            self.trackersInProgress |= MPViewabilityOptionMoat;
            MPLogInfo(@"[Viewability] MOAT tracking started");
        }
#endif
    }
}

- (void)stopTrackingMoat {
    // Only stop tracking if:
    // 1. Moat is currently tracking
    if ((self.trackersInProgress & MPViewabilityOptionMoat) == MPViewabilityOptionMoat) {
#ifdef __HAS_MOAT_FRAMEWORK_
        void (^moatEndTrackingBlock)() = ^{
            [self.moatWebTracker stopTracking];
            if (self.moatWebTracker) {
                MPLogInfo(@"[Viewability] MOAT tracking stopped");
            }
        };
        // If video, as a safeguard, dispatch `AdStopped` event before we stop tracking.
        // (MoTracker makes sure AdStopped is only dispatched once no matter how many times
        // this function is called)
        if (self.isVideo) {
            [self.webView evaluateJavaScript:kMOATSendAdStoppedJavascript
                           completionHandler:^(id result, NSError *error){
                               moatEndTrackingBlock();
                           }];
        } else {
            moatEndTrackingBlock();
        }
#endif
        // Mark Moat as not tracking
        self.trackersInProgress &= ~MPViewabilityOptionMoat;
    }
}

@end
