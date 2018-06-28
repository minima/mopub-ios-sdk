//
//  MPHTTPNetworkSession+Testing.h
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import "MPHTTPNetworkSession.h"
#import "MPHTTPNetworkTaskData.h"

@interface MPHTTPNetworkSession (Testing)

// Expose private methods
@property (nonatomic, strong) NSURLSession * sharedSession;

- (void)setSessionData:(MPHTTPNetworkTaskData *)data forTask:(NSURLSessionTask *)task;
- (MPHTTPNetworkTaskData *)sessionDataForTask:(NSURLSessionTask *)task;
- (void)appendData:(NSData *)data toSessionDataForTask:(NSURLSessionTask *)task;

@end
