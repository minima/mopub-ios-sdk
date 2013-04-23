//
//  UIApplication+MPSpecs.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UIApplication+MPSpecs.h"
#import "objc/runtime.h"

static char LAST_OPENED_URL_KEY;
static char STATUS_BAR_ORIENTATION;
static char SUPPORTED_INTERFACE_ORIENTATIONS;

@implementation UIApplication (MPSpecs)

+ (void)beforeEach
{
    [[UIApplication sharedApplication] setLastOpenedURL:nil];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
}

- (NSURL *)lastOpenedURL
{
    return objc_getAssociatedObject(self, &LAST_OPENED_URL_KEY);
}

- (void)setLastOpenedURL:(NSURL *)url
{
    objc_setAssociatedObject(self, &LAST_OPENED_URL_KEY, url, OBJC_ASSOCIATION_RETAIN);
}

- (void)openURL:(NSURL *)url
{
    self.lastOpenedURL = url;
}

- (void)setStatusBarOrientation:(UIInterfaceOrientation)orientation
{
    objc_setAssociatedObject(self, &STATUS_BAR_ORIENTATION, [NSNumber numberWithInteger:orientation], OBJC_ASSOCIATION_RETAIN);
}

- (UIInterfaceOrientation)statusBarOrientation
{
    return [objc_getAssociatedObject(self, &STATUS_BAR_ORIENTATION) integerValue];
}

- (void)setSupportedInterfaceOrientations:(UIInterfaceOrientationMask)orientationMask
{
    objc_setAssociatedObject(self, &SUPPORTED_INTERFACE_ORIENTATIONS, [NSNumber numberWithUnsignedInteger:orientationMask], OBJC_ASSOCIATION_RETAIN);
}

- (NSUInteger)supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return [objc_getAssociatedObject(self, &SUPPORTED_INTERFACE_ORIENTATIONS) unsignedIntegerValue];
}

@end
