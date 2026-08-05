# Simplenote for macOS

![Screenshot](https://simplenoteblog.files.wordpress.com/2021/09/gh-screenshot.png)

A Simplenote client for macOS. Learn more about Simplenote at [Simplenote.com](https://simplenote.com).

## Build Instructions

### Download Xcode

At the moment *Simplenote for macOS* uses Swift 5 and requires Xcode 12 or newer. Xcode can be [downloaded from Apple](https://developer.apple.com/downloads/index.action).*

### Third party tools

We use a few tools to help with development. To install or update the required dependencies, run the follow command on the command line:

`rake dependencies`

#### Why isn't Sparkle fetched with Swift Package Manager

**TL;DR** We had issues with CocoaPods in the past and haven't had the bandwidth to upgrade to SwiftPM yet.

Back in the CocoaPods days, when we tried to fetch Sparkle using it, the version distributed via CocoaPods didn't support Sandboxing, an important feature in Simplenote macOS at the time.

To distribute the beta version of Simplenote with Sparkle, we used the [`2.x`](https://github.com/sparkle-project/Sparkle/tree/2.x) branch.
See also [this issue in the Sparkle repo](https://github.com/sparkle-project/Sparkle/issues/1523).

Since then, Sparkle officially shipped their version 2, including SwiftPM support, but we haven't had a chance to upgrade yet.

If there'll be a need to work with Sparkle, ideally we should take the time to upgrade.
But just for reference, the process used so far to build from source is contained in the `./Scripts/update-sparkle.sh` script.

#### SwiftLint

We use [SwiftLint](https://github.com/realm/SwiftLint) to enforce a common style for Swift code. If you plan to write code, SwiftLint is going to be installed when you run a build from Xcode.

No commit should have lint warnings or errors.

### Open Xcode

Launch the project by running the following from the command line:

`rake xcode`

This will ensure any dependencies are ready before launching Xcode.

You can also open the project by double clicking on `Simplenote.xcworkspace` file, or launching Xcode and choose `File` > `Open` and browse to `Simplenote.xcworkspace`.

## Setup Credentials

Simplenote is powered by the [Simperium Sync'ing protocol](https://www.simperium.com), which requires credentials to authenticate the application and verify that the API calls being made are valid.

**⚠️ Please note → We're not accepting any new Simperium accounts at this time.**

Credentials live in the `simperium*` properties of the `SPCredentials` type, which is generated at build time from production credentials kept outside the checkout, falling back to user-specified ones.
When it finds neither, the build fails with instructions on how to provide them.

_Note: Simplenote API features such as sharing and publishing will not work with development builds._

## Style Guidelines

 We follow the WordPress iOS Style Guidelines, and we're constantly improving / adopting latest techniques.

 - [Swift Standard](https://github.com/wordpress-mobile/swift-style-guide)
 - [ObjC Standard](https://github.com/wordpress-mobile/objective-c-style-guide)

## Contributing

Read our [Contributing Guide](CONTRIBUTING.md) to learn about reporting issues, contributing code, and more ways to contribute.

## License

Simplenote for macOS is an Open Source project covered by the [GNU General Public License version 2](LICENSE.md).

Happy noting!
