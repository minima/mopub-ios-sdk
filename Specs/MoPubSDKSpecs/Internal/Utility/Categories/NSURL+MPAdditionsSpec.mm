#import "NSURL+MPAdditions.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NSURL_MPAdditionsSpec)

describe(@"NSURL_MPAdditions", ^{
    describe(@"mp_queryAsDictionary", ^{
        it(@"should work", ^{
            NSURL *URL = [NSURL URLWithString:@"http://www.foo.com/magic/blah?q=123%2F4&bar&foo=125=abc=====&foo=5=abc=&&mwahaha="];
            URL.mp_queryAsDictionary should equal(@{@"q": @"123/4", @"foo":@"5", @"mwahaha":@""});
        });
    });
});

SPEC_END
