//
//  MPWebView+Testing.h
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "MPWebView.h"
#import <WebKit/WebKit.h>

@interface MPWebView (Testing)
@property (weak, nonatomic) WKWebView *wkWebView;
@property (weak, nonatomic) UIWebView *uiWebView;
@end
