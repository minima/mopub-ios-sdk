//
//  MPConsentManager+Testing.m
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import "MPConsentManager+Testing.h"

// Copied from `MPConsentManager.m`
static NSString * const kConsentedIabVendorListStorageKey        = @"com.mopub.mopub-ios-sdk.consented.iab.vendor.list";
static NSString * const kConsentedPrivacyPolicyVersionStorageKey = @"com.mopub.mopub-ios-sdk.consented.privacy.policy.version";
static NSString * const kConsentedVendorListVersionStorageKey    = @"com.mopub.mopub-ios-sdk.consented.vendor.list.version";
static NSString * const kConsentStatusStorageKey                 = @"com.mopub.mopub-ios-sdk.consent.status";
static NSString * const kGDPRAppliesStorageKey                   = @"com.mopub.mopub-ios-sdk.gdpr.applies";
static NSString * const kIsDoNotTrackStorageKey                  = @"com.mopub.mopub-ios-sdk.is.do.not.track";
static NSString * const kLastChangedMsStorageKey                 = @"com.mopub.mopub-ios-sdk.last.changed.ms";
static NSString * const kLastChangedReasonStorageKey             = @"com.mopub.mopub-ios-sdk.last.changed.reason";
NSString * const kIfaForConsentStorageKey                        = @"com.mopub.mopub-ios-sdk.ifa.for.consent";
static NSString * const kShouldReacquireConsentStorageKey        = @"com.mopub.mopub-ios-sdk.should.reacquire.consent";

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
@implementation MPConsentManager (Testing)

// Override the default implementation to avoid the networking part of the code.
- (void)synchronizeConsentWithCompletion:(void (^ _Nonnull)(NSError * error))completion {
    completion(nil);
}

// Reset consent manager for testing
- (void)setUpConsentManagerForTesting {
    NSUserDefaults * defaults = NSUserDefaults.standardUserDefaults;
    [defaults setObject:nil forKey:kConsentedIabVendorListStorageKey];
    [defaults setObject:nil forKey:kConsentedPrivacyPolicyVersionStorageKey];
    [defaults setObject:nil forKey:kConsentedVendorListVersionStorageKey];
    [defaults setObject:nil forKey:kConsentStatusStorageKey];
    [defaults setInteger:MPBoolUnknown forKey:kGDPRAppliesStorageKey];
    [defaults setObject:nil forKey:kIfaForConsentStorageKey];
    [defaults setObject:nil forKey:kIsDoNotTrackStorageKey];
    [defaults setObject:nil forKey:kLastChangedMsStorageKey];
    [defaults setObject:nil forKey:kLastChangedReasonStorageKey];
    [defaults setObject:nil forKey:kShouldReacquireConsentStorageKey];
    [defaults synchronize];
}

@end
#pragma clang diagnostic pop
