//
//  MPAdserverCommunicatorDelegateHandler.m
//  MoPubSDKTests
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPAdserverCommunicatorDelegateHandler.h"

@implementation MPAdserverCommunicatorDelegateHandler

- (void)communicatorDidReceiveAdConfigurations:(NSArray<MPAdConfiguration *> *)configurations { if (self.communicatorDidReceiveAdConfigurations) self.communicatorDidReceiveAdConfigurations(configurations); }
- (void)communicatorDidFailWithError:(NSError *)error { if (self.communicatorDidFailWithError) self.communicatorDidFailWithError(error); }

@end
