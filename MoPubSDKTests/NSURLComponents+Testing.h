//
//  NSURLComponents+Testing.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLComponents (Testing)

- (NSString *)valueForQueryParameter:(NSString *)key;
- (BOOL)hasQueryParameter:(NSString *)key;

@end
