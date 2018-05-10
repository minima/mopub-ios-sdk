//
//  MoPub+Testing.h
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import "MoPub.h"

NS_ASSUME_NONNULL_BEGIN

@interface MoPub (Testing)

// This method is called by `initializeSdkWithConfiguration:completion:` in a dispatch_once block,
// and is exposed here for unit testing.
- (void)setSdkWithConfiguration:(MPMoPubConfiguration *)configuration
                     completion:(void(^_Nullable)(void))completionBlock;

@end

NS_ASSUME_NONNULL_END
