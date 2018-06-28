//
//  MPMockAdDestinationDisplayAgent.h
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdDestinationDisplayAgent.h"

@interface MPMockAdDestinationDisplayAgent : MPAdDestinationDisplayAgent

@property (nonatomic, strong) NSURL * lastDisplayDestinationUrl;

// Override existing functionality
- (void)displayDestinationForURL:(NSURL *)URL;
@end
