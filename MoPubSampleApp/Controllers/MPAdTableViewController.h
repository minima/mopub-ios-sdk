//
//  MPAdTableViewController.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPAdInfo.h"

@interface MPAdTableViewController : UITableViewController

- (id)initWithAdSections:(NSArray *)sections;
- (void)loadAd:(MPAdInfo *)info;

@end
