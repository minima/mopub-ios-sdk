//
//  XCTestCase+MPAddition.m
//  MoPubSDK
//
//  Copyright © 2017 MoPub. All rights reserved.
//

#import "XCTestCase+MPAddition.h"

@implementation XCTestCase (MPAddition)

- (NSData *)dataFromXMLFileNamed:(NSString *)name class:(Class)aClass
{
    NSString *file = [[NSBundle bundleForClass:[aClass class]] pathForResource:name ofType:@"xml"];
    return [NSData dataWithContentsOfFile:file];
}

@end
