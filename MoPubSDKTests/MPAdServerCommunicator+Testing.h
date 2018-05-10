//
//  MPAdServerCommunicator+Testing.h
//  MoPubSDKTests
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPAdServerCommunicator.h"

@interface MPAdServerCommunicator (Testing)

@property (nonatomic, assign, readwrite) BOOL loading;

// Expose private methods from `MPAdServerCommunicator`
- (void)didFinishLoadingWithData:(NSData *)data headers:(NSDictionary *)headers;

@end
