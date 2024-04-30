<br/>
<p align="center" width="100%">
    <img width="15%" src="https://github.com/verny-tran/LoadControl/blob/main/Resources/Icons/LoadControl.png"> 
</p>

<h1 align="center"> LoadControl </h1>
<p align="center"> A standard control that can initiate the loading of a scroll view’s contents. </p>
<p align="center">
    <a href="https://github.com/verny-tran/LoadControl/blob/main/.github/workflows/swift.yml"><img src="https://img.shields.io/travis/verny-tran/LoadControl.svg?style=flat)"></a>
    <a href="https://cocoapods.org/pods/LoadControl"><img src="https://img.shields.io/cocoapods/l/LoadControl.svg?style=flat"></a>
    <a href="https://swift.org/package-manager"><img src="https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat"></a>
    <a href="https://cocoapods.org/pods/LoadControl"><img src="https://img.shields.io/cocoapods/v/LoadControl.svg?style=flat"></a>
    <a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat"></a>
    <a href="https://cocoapods.org/pods/LoadControl"><img src="https://img.shields.io/badge/iOS-13.0%2B-blue.svg?style=flat"></a>
    <a href="https://cocoapods.org/pods/LoadControl"><img src="https://img.shields.io/badge/Xcode-11.0%2B-blue.svg?style=flat"></a>
    <a href="https://cocoapods.org/pods/LoadControl"><img src="https://img.shields.io/badge/Swift-5.1%2B-orange.svg?style=flat"></a>
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

### Swizzling

Be aware that this extension [swizzles](https://medium.com/@pallavidipke07/method-swizzling-in-swift-5c9d9ab008e4) `setContentOffset` 
and `setContentSize` on [UIScrollView](https://developer.apple.com/documentation/uikit/uiscrollview).

## Example

To run the example project, clone the repo, and run `pod install` from the **Demo** directory first.

### Basics

## Requirements
- **Swift** `5.1+`
- **Xcode** `11.0+`

| Platform | Installation | Status |
| -------- | ------------ | ------ |
| iOS `13.0+` (UIKit) | [CocoaPods](#cocoapods), [Carthage](#carthage), [Swift Package Manager](#swift-package-manager), [Manual](#manually) | Fully tested |
| macOS `11.0+` (AppKit) | [CocoaPods](#cocoapods), [Carthage](#carthage), [Swift Package Manager](#swift-package-manager), [Manual](#manually) | Testing |

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of **Swift** code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding **LoadControl** as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift` or the package list in **Xcode**.

1. **File** → **Swift Packages** → **Add Package Dependency**.
2. Add `https://github.com/verny-tran/LoadControl.git`.
3. Select **"Branch"** with `main`.

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

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate **LoadControl** into your **Xcode** project using **CocoaPods**, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '13.0'
use_frameworks!

target 'App' do
  pod 'LoadControl', '~> 1.0.0'
end
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate **LoadControl** into your **Xcode** project using **Carthage**, specify it in your `Cartfile`:

```ogdl
github "verny-tran/LoadControl"
```

### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate **LoadControl** into your project manually.

#### Embedded Framework

1. Open up **Terminal**, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

  ```bash
  $ git init
  ```

2. Add **LoadControl** as a git [submodule](https://git-scm.com/docs/git-submodule) by running the following command:

  ```bash
  $ git submodule add https://github.com/verny-tran/LoadControl.git
  ```

3. Open the new `LoadControl` folder, and drag the `LoadControl.xcodeproj` into the **Project Navigator** of your application's **Xcode** project.

  > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other **Xcode** groups does not matter.

4. Select the `LoadControl.xcodeproj` in the **Project Navigator** and verify the deployment target matches that of your application target.
5. Next, select your application project in the **Project Navigator** (blue project icon) to navigate to the target configuration window and select the application target under the **"Targets"** heading in the sidebar.
6. In the tab bar at the top of that window, open the **"General"** panel.
7. Click on the `+` button under the **"Embedded Binaries"** section.
8. You will see two different `LoadControl.xcodeproj` folders each with two different versions of the `LoadControl.framework` nested inside a `Products` folder.

  > It does not matter which `Products` folder you choose from, but it does matter whether you choose the top or bottom `LoadControl.framework`.

9. Select the top `LoadControl.framework` for **iOS**.

  > You can verify which one you selected by inspecting the build log for your project. The build target for `LoadControl` will be listed as `LoadControlKit`.

10. And that's it!

  > The `LoadControl.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

## Inspiration
The features of **LoadControl** is heavily inspired by, and is a *totally Swifted* version of the project [**UIScrollView-InfiniteScroll**](https://github.com/pronebird/UIScrollView-InfiniteScroll) by [Andrej Mihajlov (`pronebird`)](https://github.com/pronebird). Now you don't need the following line in your `Bridging-Header.h` file anymore.

```objc
#import <LoadControl/LoadControl.h>
```

## Authors

- **Trần T. Dũng** (Verny), vernytran@icloud.com
- **Võ C. Kha** (Zach), khavo0704@gmail.com

### Contact

Follow and contact me on [LinkedIn](https://www.linkedin.com/in/vernytran) or [Medium](https://medium.com/@vernytran). If you find an issue, [open a ticket](https://github.com/verny-tran/LoadControl/issues/new). Pull requests are warmly welcome as well.

## License

**LoadControl** is available under the **MIT** license. See the `LICENSE` file for more info.
