//
//  NSURLSessionTask+Testing.h
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSessionTask (Testing)
@property (nullable, readwrite, copy) NSURLResponse *response;
@end
