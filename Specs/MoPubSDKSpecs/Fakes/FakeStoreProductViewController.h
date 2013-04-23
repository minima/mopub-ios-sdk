//
//  FakeStoreProductViewController.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface FakeStoreProductViewController : SKStoreProductViewController

@property (nonatomic, assign) NSString *storeItemIdentifier;
@property (nonatomic, copy) void (^completionBlock)(BOOL result, NSError *error);

@end
