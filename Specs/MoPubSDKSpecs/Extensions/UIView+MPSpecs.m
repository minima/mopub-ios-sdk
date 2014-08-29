//
//  UIView+MPSpecs.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "UIView+MPSpecs.h"
#import "MPGlobal.h"

@implementation UIView (MPSpecs)

- (BOOL)mp_viewIntersectsKeyWindowWithPercent:(CGFloat)percentVisible
{
    return MPViewIntersectsKeyWindowWithPercent(self, percentVisible);
}

- (BOOL)mp_viewIntersectsApplicationWindowWithPercent:(CGFloat)percentVisible
{
    return MPViewIntersectsApplicationWindowWithPercent(self, percentVisible);
}

- (BOOL)mp_viewIsVisible
{
    return MPViewIsVisible(self);
}

@end
