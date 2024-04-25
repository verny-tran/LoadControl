<br/>
<p align="center" width="100%">
    <img width="15%" src="https://github.com/verny-tran/LoadControl/blob/main/Resources/Icons/LoadControl.png"> 
</p>

<h1 align="center"> LoadControl </h1>
<p align="center"> A standard control that can initiate the loading of a scroll view’s contents.
    [![CI Status](https://img.shields.io/travis/verny-tran/LoadControl}.svg?style=flat)](https://travis-ci.org/verny-tran/LoadControl})
    [![Version](https://img.shields.io/cocoapods/v/LoadControl.svg?style=flat)](https://cocoapods.org/pods/LoadControl)
    [![License](https://img.shields.io/cocoapods/l/LoadControl.svg?style=flat)](https://cocoapods.org/pods/LoadControl)
    [![Platform](https://img.shields.io/cocoapods/p/LoadControl.svg?style=flat)](https://cocoapods.org/pods/LoadControl)
    [![SPM](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager/)
</p>

## Features
- [x] Footer loading indicator.
- [x] Scroll, pull up to load (with haptic feedback).
- [x] Horizontal loading for *collection views*.
- [x] Customizable *insets*, *offsets*, *margins* and *directions*.
- [ ] Customizable activity indicator.

### The reversed **refresh control**

Similar to the behaviors and implementation of the [UIRefreshControl](https://developer.apple.com/documentation/uikit/uirefreshcontrol):
```swift
self.tableView.refreshControl = UIRefreshControl()
self.tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

@objc
private func refresh()
```

The **LoadControl** is the *reversed* version of a **refresh control**, use to load more items from a list of contents. The simplest use-case is adding an action selector to a target with the [UIScrollView](https://developer.apple.com/documentation/uikit/uiscrollview) extension:

```swift
import LoadControl

self.tableView.loadControl = LoadControl()
self.tableView.loadControl?.addTarget(self, action: #selector(load), for: .valueChanged)

@objc
private func load()
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
- **Swift** `5.0+`
- **Xcode** `13.0+`

| Platform | Installation | Status |
| -------- | ------------ | ------ |
| iOS `13.0+` (UIKit) | [CocoaPods](#cocoapods), [Carthage](#carthage), [Swift Package Manager](#swift-package-manager), [Manual](#manually) | Fully tested |
| macOS `10.12+` (UIKit) | [CocoaPods](#cocoapods), [Carthage](#carthage), [Swift Package Manager](#swift-package-manager), [Manual](#manually) | Testing |

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of **Swift** code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding **LoadControl** as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift` or the Package list in Xcode.

- File → Swift Packages → Add Package Dependency.
- Add `https://github.com/verny-tran/LoadControl.git`.
- Select "Up to Next Major" with `1.0.0`.

```swift
dependencies: [
    .package(url: "https://github.com/verny-tran/LoadControl.git", .upToNextMajor(from: "1.0.0"))
]
```

Normally you'll want to depend on the `LoadControl` target:

```swift
.product(name: "verny-tran", package: "LoadControl")
```

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate **LoadControl** into your Xcode project using **CocoaPods**, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '13.0'
use_frameworks!

target 'App' do
  pod 'LoadControl', '~> 1.0'
end
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate **LoadControl** into your Xcode project using **Carthage**, specify it in your `Cartfile`:

```ogdl
github "verny-tran/LoadControl"
```

## Authors

- **Trần T. Dũng** (Verny), vernytran@icloud.com
- **Võ C. Kha** (Zach), khavo0704@gmail.com

## License

**LoadControl** is available under the **MIT** license. See the `LICENSE` file for more info.
