//
//  MPAdRequestError.h
//  MoPub
//
//  Copyright (c) 2012 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kMPErrorDomain;

typedef enum {
    MOPErrorUnknown = -1,
    MOPErrorNoInventory = 0,
    MOPErrorAdUnitWarmingUp = 1,
    MOPErrorNetworkTimedOut = 4,
    MOPErrorServerError = 8,
    MOPErrorAdapterNotFound = 16,
    MOPErrorAdapterInvalid = 17,
    MOPErrorAdapterHasNoInventory = 18
} MOPErrorCode;

@interface MPError : NSError

+ (MPError *)errorWithCode:(MOPErrorCode)code;

@end
