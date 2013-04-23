//
//  KIFTestStep+Navigation.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestStep+Navigation.h"

@implementation KIFTestStep (Navigation)

+ (id)stepToReturnToBannerAds
{
    return [KIFTestStep stepWithDescription:@"Return to Banner Ads" executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {
        UIViewController *topViewController = [KIFHelper topMostViewController];
        UINavigationController *navigationController = [topViewController navigationController];
        [navigationController popToRootViewControllerAnimated:YES];
        [KIFHelper waitForViewControllerToStopAnimating:topViewController];
        return KIFTestStepResultSuccess;
    }];
}

@end
