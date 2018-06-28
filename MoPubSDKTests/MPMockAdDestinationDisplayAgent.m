//
//  MPMockAdDestinationDisplayAgent.m
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import "MPMockAdDestinationDisplayAgent.h"

@implementation MPMockAdDestinationDisplayAgent

- (void)displayDestinationForURL:(NSURL *)URL {
    self.lastDisplayDestinationUrl = URL;
}

@end
