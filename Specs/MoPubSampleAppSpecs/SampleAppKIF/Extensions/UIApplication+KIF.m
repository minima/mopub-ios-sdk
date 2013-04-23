//
//  UIApplication+KIF.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UIApplication+KIF.h"

@implementation UIApplication (KIF)

- (void)openURL:(NSURL *)url
{
    NSLog(@"================> Application tried to open: %@", url);
}

@end
