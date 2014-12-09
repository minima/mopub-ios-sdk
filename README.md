# MoPub iOS SDK

Thanks for taking a look at MoPub! We take pride in having an easy-to-use, flexible monetization solution that works across multiple platforms.

Sign up for an account at [http://app.mopub.com/](http://app.mopub.com/).

Help is available on the [wiki](https://github.com/mopub/mopub-ios-sdk/wiki/Getting-Started), detailed class documentation is available at [ClassDocumentation](http://htmlpreview.github.com/?https://github.com/mopub/mopub-ios-sdk/blob/master/ClassDocumentation/index.html)

**We have launched a new license as of version 3.2.0.** To view the full license, visit [http://www.mopub.com/legal/sdk-license-agreement/](http://www.mopub.com/legal/sdk-license-agreement/)

## Download

The MoPub SDK is distributed as source code that you can include in your application.  MoPub provides two prepackaged archives of source code:

- **[MoPub Full SDK.zip](http://bit.ly/180lUGi)**

  Includes everything you need to serve HTML, MRAID, and Native MoPub advertisiments *and* built-in support for three major third party ad networks - [iAd](http://advertising.apple.com/), [Google AdMob](http://www.google.com/ads/admob/), and [Millennial Media](http://www.millennialmedia.com/) - including the required third party binaries.

- **[MoPub Base SDK.zip](http://bit.ly/19pPR1r)**

  Includes everything you need to serve HTML, MRAID, and Native MoPub advertisements.  No third party ad networks are included.

The current version of the SDK is 3.3.0

## Integrate

Integration instructions are available on the [wiki](https://github.com/mopub/mopub-ios-sdk/wiki/Getting-Started).

More detailed class documentation is available in the repo under the `ClassDocumentation` folder.  This can be viewed [online too](http://htmlpreview.github.com/?https://github.com/mopub/mopub-ios-sdk/blob/master/ClassDocumentation/index.html).

## New in this Version

Please view the [changelog](https://github.com/mopub/mopub-ios-sdk/blob/master/CHANGELOG.md) for details.

- **MRAID 2.0 support**. The MoPub SDK is now compliant with the MRAID 2.0 specification to enable rich media ads in banners and interstitial ad units. Learn more about MRAID from the [IAB](http://www.iab.net/MRAID#MRAID). To minimize integration errors, please completely remove the existing MoPub SDK from your project and then integrate the latest version.
- **Automatic geolocation updates**. If your app already has location permissions, the MoPub SDK will automatically attempt to acquire location data for ad requests. Please use `locationUpdatesEnabled` in `MoPub.h` to opt out of this functionality. The MoPub SDK will never prompt the user for permission if location permissions are not currently granted.
- **Added support for AdColony SDK 2.4.12**.
- **Bug fixes**.

### IMPORTANT UPGRADE INSTRUCTIONS

As of version 3.0.0, the MoPub SDK uses Automatic Reference Counting. If you're upgrading from an earlier version (2.4.0 or earlier) that uses Manual Reference Counting, in order to minimize integration errors with the manual removal of the `-fno-objc-arc` compiler flag, our recommendation is to completely remove the existing MoPub SDK from your project and then integrate the latest version. Alternatively, you can manually remove the `-fno-objc-arc` compiler flag from all MoPub SDK files. If your project uses Manual Reference Counting, you must add the `-fobjc-arc` compiler flag to all MoPub SDK files.

## Requirements

iOS 5.0 and up

## License

We have launched a new license as of version 3.2.0. To view the full license, visit [http://www.mopub.com/legal/sdk-license-agreement/](http://www.mopub.com/legal/sdk-license-agreement/)