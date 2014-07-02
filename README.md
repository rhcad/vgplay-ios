# TouchVG Demo for iOS

This is a unit test and example project for [TouchVG](https://github.com/touchvg/vgios), which is a lightweight 2D vector drawing framework for iOS.

![arch](http://touchvg.github.io/images/arch.svg)

## License

This is an open source [LGPL 2.1](LICENSE.md) licensed project. It uses the following open source projects:

- [TouchVG](https://github.com/touchvg/vgios) (LGPL): Vector drawing framework for iOS.
- [TouchVGCore](https://github.com/touchvg/vgcore) (LGPL): Cross-platform vector drawing libraries using C++.

## How to Compile

### Compile with CocoaPods

Type `pod install` or `pod update --no-repo-update`, then open `TestView.xcworkspace` in Xcode and run the `TestView` demo app.

- To run on device, you may need to change the Bundle Identifier of the demo application, such as "com.yourcompany.TestView", and choose your own development certificate (Code Signing).

### Compile without CocoaPods

Alternatively, you can build as one of the following methods:

- Cd the folder of this project and type `./build.sh` or `./build.sh -arch arm64` to checkout and build libraries needed.

- Open `TestView.xcworkspace` in Xcode, then run the `TestView` demo app (Need to build each library while not type `./build.sh`).

## How to Contribute

Contributors and sponsors are welcome. You may translate, commit issues or pull requests on this Github site.
To contribute, please follow the branching model outlined here: [A successful Git branching model](http://nvie.com/posts/a-successful-git-branching-model/).

Welcome to the Chinese QQ group `192093613` to discuss and share.
