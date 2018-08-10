//
//  MPViewController.h
//  MoPubSampleApp
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MPViewController : UIViewController
@property (nonatomic, readonly) NSTimeInterval lastTimeInterval;

- (void)startTimer;
- (void)endTimer;
@end
