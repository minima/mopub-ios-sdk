//
//  NSURLComponents+Testing.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "NSURLComponents+Testing.h"

@implementation NSURLComponents (Testing)

- (NSString *)valueForQueryParameter:(NSString *)key {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", key];
    NSURLQueryItem *queryItem = [[self.queryItems filteredArrayUsingPredicate:predicate] firstObject];
    return queryItem.value;
}

- (BOOL)hasQueryParameter:(NSString *)key {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name=%@", key];
    return [self.queryItems filteredArrayUsingPredicate:predicate].count > 0;
}

@end
