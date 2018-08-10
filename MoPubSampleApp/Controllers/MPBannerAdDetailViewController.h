//
//  MPBannerAdDetailViewController.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPAdView.h"
#import "MPViewController.h"

@class MPAdInfo;

@interface MPBannerAdDetailViewController : MPViewController <MPAdViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *IDLabel;
@property (weak, nonatomic) IBOutlet UIView *adViewContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UILabel *failLabel;

- (id)initWithAdInfo:(MPAdInfo *)info;

@end
