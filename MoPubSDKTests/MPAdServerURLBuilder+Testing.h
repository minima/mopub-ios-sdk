//
//  MPAdServerURLBuilder+Testing.h
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import "MPAdServerURLBuilder.h"

@interface MPAdServerURLBuilder (Testing)

+ (NSString *)queryItemForKey:(NSString *)key value:(NSString *)value;
+ (NSString *)queryParameterForAdvancedBidding;
+ (NSString *)queryParameterForConsent;

@end
