//
//  MPAdserverCommunicatorDelegateHandler.h
//  MoPubSDKTests
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdServerCommunicator.h"

@interface MPAdserverCommunicatorDelegateHandler : NSObject <MPAdServerCommunicatorDelegate>

@property (nonatomic, copy) void (^communicatorDidReceiveAdConfigurations)(NSArray<MPAdConfiguration *> *configurations);
@property (nonatomic, copy) void (^communicatorDidFailWithError)(NSError *error);

@end
