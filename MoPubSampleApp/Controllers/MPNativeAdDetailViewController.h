//
//  MPNativeAdDetailViewController.h
//  MoPub
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPViewController.h"

@class MPAdInfo;

extern NSString *const kNativeAdDefaultActionViewKey;

@interface MPNativeAdDetailViewController : MPViewController

- (id)initWithAdInfo:(MPAdInfo *)info;

@end
