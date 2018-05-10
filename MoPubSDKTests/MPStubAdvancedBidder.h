//
//  MPStubAdvancedBidder.h
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdvancedBidder.h"

@interface MPStubAdvancedBidder : NSObject <MPAdvancedBidder>
@property (nonatomic, copy, readonly) NSString * _Nonnull creativeNetworkName;
@property (nonatomic, copy, readonly) NSString * _Nonnull token;
@end
