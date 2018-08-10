//
//  MPMockAdServerCommunicator.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPAdServerCommunicator.h"

@interface MPMockAdServerCommunicator : MPAdServerCommunicator
@property (nonatomic, strong) NSArray<MPAdConfiguration *> * mockConfigurationsResponse;
@property (nonatomic, strong) NSURL * lastUrlLoaded;
@property (nonatomic, assign) BOOL loadMockResponsesOnce;
@property (nonatomic, assign) NSUInteger numberOfBeforeLoadEventsFired;
@property (nonatomic, assign) NSUInteger numberOfAfterLoadEventsFired;
@property (nonatomic, assign) BOOL lastAfterLoadResultWasTimeout;

- (void)loadURL:(NSURL *)URL;

@end
