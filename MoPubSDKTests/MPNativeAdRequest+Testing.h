//
//  MPNativeAdRequest+Testing.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPNativeAdRequest.h"
#import "MPAdServerCommunicator.h"

@interface MPNativeAdRequest (Testing) <MPAdServerCommunicatorDelegate>
@property (nonatomic, strong) MPAdServerCommunicator * communicator;
@end
