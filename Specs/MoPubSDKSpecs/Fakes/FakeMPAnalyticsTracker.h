//
//  FakeMPAnalyticsTracker.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAnalyticsTracker.h"

@interface FakeMPAnalyticsTracker : MPAnalyticsTracker

@property (nonatomic, assign) NSMutableArray *trackedImpressionConfigurations;
@property (nonatomic, assign) NSMutableArray *trackedClickConfigurations;

- (void)reset;

@end
