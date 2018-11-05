# Zapic SDK for iOS

[![Build Status](https://travis-ci.org/ZapicInc/Zapic-SDK-iOS.svg?branch=master)](https://travis-ci.org/ZapicInc/Zapic-SDK-iOS) [![CodeFactor](https://www.codefactor.io/repository/github/zapicinc/zapic-sdk-ios/badge)](https://www.codefactor.io/repository/github/zapicinc/zapic-sdk-ios) [![MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage) ![Discord](https://img.shields.io/discord/430949891104309249.svg)

Copyright (c) 2017-2018 Zapic, Inc.

The Zapic SDK for iOS is an open-source project that allows game developers to integrate with the Zapic platform from a game written in Swift or Objective-C for iOS.

_iOS is a trademark of Apple, Inc._

## Getting Started

Learn more about integrating the SDK and configuring your iOS game in the Zapic platform at https://www.zapic.com/docs/ios.

## Community

Chat on [Discord](https://discord.gg/Kduh53S).

Follow [@ZapicInc](https://twitter.com/ZapicInc) on Twitter for important announcements.

Report bugs and discuss new features on [GitHub](https://github.com/ZapicInc/Support).

## Contributing

We accept contributions to the Zapic SDK for iOS. Simply fork the repository and submit a pull request on [GitHub](https://github.com/ZapicInc/Zapic-SDK-iOS/pulls).

## Quick Links

* [Zapic Documentation](https://docs.zapic.com)
* [Zapic SDK for Unity](https://github.com/ZapicInc/Zapic-SDK-Unity)
* [Zapic SDK for Android](https://github.com/ZapicInc/Zapic-SDK-Android)

## How to create a release
1. Update version number of Zapic project
2. Update version number of podspec
3. Check pod `pod lib lint`
4. Create release in Github
5. Publish release to Cocoapods repo `pod trunk push Zapic.podspec`
