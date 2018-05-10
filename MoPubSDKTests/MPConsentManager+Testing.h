//
//  MPConsentManager+Testing.h
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import "MPConsentManager.h"

extern NSString * _Nonnull const kIfaForConsentStorageKey;

@interface MPConsentManager (Testing)
- (BOOL)setCurrentStatus:(MPConsentStatus)currentStatus
                  reason:(NSString * _Nullable)reasonForChange
         shouldBroadcast:(BOOL)shouldBroadcast;
- (BOOL)updateConsentStateWithParameters:(NSDictionary * _Nonnull)newState;
- (NSURL * _Nullable)urlWithFormat:(NSString * _Nullable)urlFormat isoLanguageCode:(NSString * _Nullable)isoLanguageCode;

// Reset consent manager state for testing
- (void)setUpConsentManagerForTesting;
@end
