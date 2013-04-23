//
//  MPSampleAppTestScenario.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPSampleAppTestScenario.h"
#import "KIFTestStep.h"


@implementation MPSampleAppTestScenario

- (void)addStep:(KIFTestStep *)step
{
    [super addStep:step];
    if (getenv("KIF_SLOW_TESTS")) {
        [super addStep:[KIFTestStep stepToWaitForTimeInterval:0.5 description:@"Waiting for half a second."]];
    }
}

@end
