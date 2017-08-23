//
//  MPMockAdServerCommunicator.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPAdServerCommunicator.h"

@interface MPMockAdServerCommunicator : MPAdServerCommunicator
@property (nonatomic, strong) NSURL * lastUrlLoaded;

- (void)loadURL:(NSURL *)URL;

@end
