//
//  MPMRAIDInterstitialViewController.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPInterstitialViewController.h"

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MPMRAIDInterstitialViewControllerDelegate;
@class MPAdConfiguration;

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPMRAIDInterstitialViewController : MPInterstitialViewController

- (id)initWithAdConfiguration:(MPAdConfiguration *)configuration;
- (void)startLoading;

@end

