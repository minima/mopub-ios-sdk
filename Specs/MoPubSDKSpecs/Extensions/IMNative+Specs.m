//
//  IMNative+Specs.m
//  MoPubSDK
//
//  Copyright (c) 2014 MoPub. All rights reserved.
//

#import "IMNative+Specs.h"
#import "IMNativeDelegate.h"

@implementation IMNative (Specs)

- (void)loadAd
{
    [self.delegate nativeAdDidFinishLoading:self];
}

- (NSString *)content
{
    return @"{\"title\":\"Ad Title String\",\"landing_url\":\"https://appstorelink.com\",\"screenshots\":{\"w\":568,\"ar\":1.77,\"url\":\"http://thestartuplegitimizer.com/logos/asfeatured.png\",\"h\":320},\"icon\":{\"w\":568,\"ar\":1.77,\"url\":\"http://thestartuplegitimizer.com/logos/asfeatured.png\",\"h\":320},\"cta\":\"cta text\",\"description\":\"Description body text\"}";
}

@end
