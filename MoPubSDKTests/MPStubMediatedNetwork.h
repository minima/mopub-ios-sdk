//
//  MPStubMediatedNetwork.h
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPMediationSdkInitializable.h"

@interface MPStubMediatedNetwork : NSObject <MPMediationSdkInitializable>

- (void)initializeSdkWithParameters:(NSDictionary * _Nullable)parameters;

@end


@interface MPStubMediatedNetworkTwo : NSObject <MPMediationSdkInitializable>

- (void)initializeSdkWithParameters:(NSDictionary * _Nullable)parameters;

@end
