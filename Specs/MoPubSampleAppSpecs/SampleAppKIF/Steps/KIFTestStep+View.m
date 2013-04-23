//
//  KIFTestStep+View.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestStep+View.h"
#import "UIView-KIFAdditions.h"

@implementation KIFTestStep (View)

+ (KIFTestStep *)stepToWaitForPresenceOfViewWithClassName:(NSString *)className
{
    NSString *description = [NSString stringWithFormat:@"Looking for view with class name %@", className];
    return [KIFTestStep stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {

        NSArray *views = [[[UIApplication sharedApplication] keyWindow] subviewsWithClassNamePrefix:className];

        KIFTestWaitCondition(views.count > 0, error, @"Waiting for view with classname %@ to appear", className);

        return KIFTestStepResultSuccess;
    }];
}

+ (KIFTestStep *)stepToWaitForAbsenceOfViewWithClassName:(NSString *)className
{
    NSString *description = [NSString stringWithFormat:@"Waiting for view with class name %@ to disappear", className];
    return [KIFTestStep stepWithDescription:description executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {

        NSArray *views = [[[UIApplication sharedApplication] keyWindow] subviewsWithClassNamePrefix:className];

        KIFTestWaitCondition(views.count == 0, error, @"Waiting for view with classname %@ to disappear", className);

        return KIFTestStepResultSuccess;
    }];
}

@end
