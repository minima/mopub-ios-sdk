//
//  MPURLRequestTests.m
//  MoPubSDKTests
//
//  Copyright © 2018 MoPub. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MPURLRequest+Testing.h"

@interface MPURLRequestTests : XCTestCase

@end

@implementation MPURLRequestTests

#pragma mark - JSON Building

- (void)testNotPercentEncodedQueryParameters {
    NSURL * url = [NSURL URLWithString:@"https://www.test.com/t1?a=1&b=2"];
    NSURLComponents * components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    XCTAssertNotNil(components);

    NSDictionary * json = [MPURLRequest jsonFromURLComponents:components];
    XCTAssertNotNil(json);
    XCTAssert(json.count > 0);

    XCTAssert([json[@"a"] isEqualToString:@"1"]);
    XCTAssert([json[@"b"] isEqualToString:@"2"]);
}

- (void)testWithPercentEncodedQueryParameters {
    NSURL * url = [NSURL URLWithString:@"https://www.test.com/t2?a=i%20am%20a%20cat%20meow&b=2"];
    NSURLComponents * components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    XCTAssertNotNil(components);

    NSDictionary * json = [MPURLRequest jsonFromURLComponents:components];
    XCTAssertNotNil(json);
    XCTAssert(json.count > 0);

    XCTAssert([json[@"a"] isEqualToString:@"i am a cat meow"]);
    XCTAssert([json[@"b"] isEqualToString:@"2"]);
}

- (void)testNoQueryParameters {
    NSURL * url = [NSURL URLWithString:@"https://www.test.com/t3"];
    NSURLComponents * components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    XCTAssertNotNil(components);

    NSDictionary * json = [MPURLRequest jsonFromURLComponents:components];
    XCTAssertNotNil(json);
    XCTAssert(json.count == 0);
}

- (void)testAggregatingQueryParameters {
    NSURL * url = [NSURL URLWithString:@"https://www.test.com/t3?a=i%20am%20a%20cat%20meow&b=2&a=10"];
    NSURLComponents * components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    XCTAssertNotNil(components);

    NSDictionary * json = [MPURLRequest jsonFromURLComponents:components];
    XCTAssertNotNil(json);
    XCTAssert(json.count > 0);

    XCTAssert([json[@"a"] isEqualToString:@"i am a cat meow,10"]);
    XCTAssert([json[@"b"] isEqualToString:@"2"]);
}

- (void)testFragmentQueryParameter {
    NSURL * url = [NSURL URLWithString:@"https://www.test.com/t1?a=1&fragment"];
    NSURLComponents * components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    XCTAssertNotNil(components);

    NSDictionary * json = [MPURLRequest jsonFromURLComponents:components];
    XCTAssertNotNil(json);
    XCTAssert(json.count > 0);

    XCTAssert([json[@"a"] isEqualToString:@"1"]);
    XCTAssert([json.allKeys containsObject:@"fragment"]);
    XCTAssert([json[@"fragment"] isEqualToString:@""]);
}

- (void)testPercentDecodingReservedCharacters {
    // Reserved characters that are percent encoded are:
    //
    // !    #    $    &    '    (    )    *    +    ,    /    :    ;    =    ?    @    [    ]
    // %21    %23    %24    %26    %27    %28    %29    %2A    %2B    %2C    %2F    %3A    %3B    %3D    %3F    %40    %5B    %5D
    // Source: https://en.wikipedia.org/wiki/Percent-encoding#Percent-encoding_reserved_characters

    NSURL * url = [NSURL URLWithString:@"https://www.test.com/t5?z=%21%23%24%26%27%28%29%2A%2B%2C%2F%3A%3B%3D%3F%40%5B%5D"];
    NSURLComponents * components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    XCTAssertNotNil(components);

    NSDictionary * json = [MPURLRequest jsonFromURLComponents:components];
    XCTAssertNotNil(json);
    XCTAssert(json.count > 0);

    XCTAssert([json[@"z"] isEqualToString:@"!#$&'()*+,/:;=?@[]"]);
}

- (void)testMultipleFragmentQueryParameter {
    NSURL * url = [NSURL URLWithString:@"https://www.test.com/t7?a&a&a&a"];
    NSURLComponents * components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    XCTAssertNotNil(components);

    NSDictionary * json = [MPURLRequest jsonFromURLComponents:components];
    XCTAssertNotNil(json);
    XCTAssert(json.count > 0);

    XCTAssert([json[@"a"] isEqualToString:@",,,"]);
}

- (void)testDecodingVariantVersionQueryParameter {
    NSURL * url = [NSURL URLWithString:@"https://www.test.com/t9?nv=5.0.0+variant"];
    NSURLComponents * components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    XCTAssertNotNil(components);

    NSDictionary * json = [MPURLRequest jsonFromURLComponents:components];
    XCTAssertNotNil(json);
    XCTAssert(json.count > 0);

    XCTAssert([json[@"nv"] isEqualToString:@"5.0.0+variant"]);
}

@end
