//
//  MPURLRequest+Testing.h
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import "MPURLRequest.h"

@interface MPURLRequest (Testing)
+ (NSDictionary *)jsonFromURLComponents:(NSURLComponents *)components;
@end
