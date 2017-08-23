//
//  MPMockAdServerCommunicator.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPMockAdServerCommunicator.h"

@implementation MPMockAdServerCommunicator

- (void)loadURL:(NSURL *)URL {
    self.lastUrlLoaded = URL;
}

@end
