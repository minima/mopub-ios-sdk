//
//  MPAdvancedBiddingManager+Testing.h
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import "MPAdvancedBiddingManager.h"

@interface MPAdvancedBiddingManager (Testing)
@property (nonatomic, strong) NSMutableDictionary<NSString *, id<MPAdvancedBidder>> * bidders;
@end
