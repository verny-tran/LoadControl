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
- [x] Scroll, pull up to load with paging behavior (and *haptic feedback*).
- [x] Horizontal loading for *collection views*.
- [x] Customizable *insets*, *offsets*, *margins* and *directions*.
- [ ] Customizable *activity indicator*.
- [ ] **SwiftUI** support.

|     Refresh Control    |   Load Control  |
|         :----:         |      :----:     |
| ![](https://github.com/verny-tran/LoadControl/blob/main/Resources/Images/Refresh.gif) | ![](https://github.com/verny-tran/LoadControl/blob/main/Resources/Images/Load.gif) |

### The reversed **refresh control**

Similar to the behaviors and implementation of the [**UIRefreshControl**](https://developer.apple.com/documentation/uikit/uirefreshcontrol):
```swift
self.tableView.refreshControl = UIRefreshControl()
self.tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

@objc
private func refresh()
```

The **load control** is the *reversed* version of a **refresh control**, use to load more items from a list of contents. The simplest use-case is adding an action selector to a target with the [**UIScrollView**](https://developer.apple.com/documentation/uikit/uiscrollview) extension:

```swift
import LoadControl

self.tableView.loadControl = LoadControl()
self.tableView.loadControl?.addTarget(self, action: #selector(load), for: .valueChanged)

@objc
private func load()
```

### Swizzling

Be aware that this extension [swizzles](https://medium.com/@pallavidipke07/method-swizzling-in-swift-5c9d9ab008e4) the setters of `.contentOffset` 
and `.contentSize` on [**UIScrollView**](https://developer.apple.com/documentation/uikit/uiscrollview).

### Customizable indicator & SwiftUI support

Currently, the **LoadControl** does not permit customizing the loading animation; instead, it simply displays the default [**UIActivityIndicatorView**](https://developer.apple.com/documentation/uikit/uiactivityindicatorview). Additionally, a [**SwiftUI**](https://developer.apple.com/xcode/swiftui) version is missing. Both of these features will be *available soon*.

## Example

This component comes with example app written in **Swift**. To run the example project, if you use [CocoaPods](https://cocoapods.org), you can try it by running:

```bash
$ pod try LoadControl
```

### Basics

In order to enable infinite loading control you have to provide an action handler as target selector using [`addTarget(_:action:for:)`](https://developer.apple.com/documentation/uikit/uicontrol/1618259-addtarget). The block you provide is executed each time the load control detects that more data needs to be provided. The handler's function is to do asynchronous tasks, such as networking or database fetch, and update your *scroll view* or it's subclass.

The block is called from the main queue, so make sure to send any long-running jobs to the background queue. Once you have received fresh data, update the *table view* by adding new rows and sections, and then use `endLoading()` to end the animations and reset the state of the control's components. [`viewDidLoad()`](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621495-viewdidload) is a nice location to add the target selector.

Ensure that any interactions with [**UIKit**](https://developer.apple.com/documentation/uikit) or methods supplied by **LoadControl** occur on the main queue. In Swift, use [`async(group:qos:flags:execute:)`](https://developer.apple.com/documentation/dispatch/dispatchqueue/2016098-async) to conduct UI-related calls on [`DispatchQueue.main`](https://developer.apple.com/documentation/dispatch/dispatchqueue/1781006-main). Many people make the mistake of utilizing an external reference to a *table or collection view* within the action handler. Do not do this since it causes a cyclic retention. Instead, send the instance of scroll view or scroll view subclass as the first parameter to the block.

To access the associated container scroll view of the **load control**, make a call to the property `.scrollView`:

```swift
if self.loadControl?.scrollView is UITableView
```

### Collection view quirks

[**UICollectionView**](https://developer.apple.com/documentation/uikit/uicollectionview)'s [`reloadData()`](https://developer.apple.com/documentation/uikit/uicollectionview/1618078-reloaddata) resets the `.contentOffset` value. Instead use [`performBatchUpdates(_:completion:)`](https://developer.apple.com/documentation/uikit/uicollectionview/1618045-performbatchupdates) if possible.

```swift
self.collectionView.loadControl?.endLoading(completion: { scrollView in
    let collectionView = scrollView as? UICollectionView
    
    collectionView?.performBatchUpdates({ () -> Void in
        // Update collection view
    })
})
```

If you want your collection view to load contents *horizontally*, set the `.direction` value to `.horizontal`:

```swift
self.collectionView.loadControl?.direction = .horizontal
```

### Begin loading programmatically

You can utilize the infinite loading flow to load initial data or use `beginLoading(_:)` to retrieve additional. [`viewDidLoad()`](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621495-viewdidload) is an excellent spot to load initial data, but the decision is entirely up to you. When the`scrollToBottom` option is set to `true` (and it is `true` by default), the **load control** will try to scroll down to display the *activity indicator view*. Keep in mind that scrolling does not occur if the user interacts with the scroll view.

```swift
self.tableView.loadControl?.beginLoading(true)
```

To check if the **load control** is currently loading or not, access the property `.isLoading`:

```swift
/// Is currently in a middle of a loading event.
print(self.tableView.loadControl?.isLoading)
```

### Prevent infinite scroll

Sometimes you need to stop the infinite loading from continuing. For example, if your search `API` returns no further results, it makes no sense to continue sending calls or displaying the *activity indicator*.

```swift
/// Change the flag value just before a load more event occurs.
self.tableView.loadControl?.shouldShowActivityIndicator = self.currentPage < 5

/// Or set ``true`` to allow or ``false`` to prevent it from triggering.
self.tableView.loadControl?.shouldShowActivityIndicator = self.viewModel.isEnded
```

### Seamlessly preload content

Perhaps you want your content to flow without ever displaying an activity indicator. **LoadControl** allows you to provide an offset in points that will be utilized to start the preloader before the user reaches the bottom of the scroll view. A proper balance between the number of results loaded each time and a large enough offset should provide your users with a satisfactory experience. Most likely, you will have to develop your own method for combining those based on the type of content and device size.

```swift
/// Preload additional data 200 screen points prior to hitting the bottom of the scroll view.
self.tableView.loadControl?.triggerOffset = 200
```

### Adjust layout attributes

Some layout attributes of the **LoadControl** is adjustable, including *insets*, *offsets* and *margins*. Try adjusting these settings to find what best meets your demands:

```swift
/// Indicator view inset. Essentially `is equal to indicator view height`.
self.tableView.loadControl?.indicatorInset = 50
    
/// `Extra padding` to push indicator view outside view bounds.
/// Used in case `when content size` is `smaller than view bounds`.
self.tableView.loadControl?.extraEndInset = 0
    
/// Flag `used to return user back to start` of scroll view when loading initial content.
self.tableView.loadControl?.scrollToStartWhenFinished = false
    
/// Indicator view margin: `top & bottom for vertical`
/// direction or `left & right for horizontal` direction.
self.tableView.loadControl?.indicatorMargin = 25
```

### Haptic feedback

For example, suppose you have ran out of data and are at the end of the list. **LoadControl** mimics the [**UIRefreshControl**](https://developer.apple.com/documentation/uikit/uirefreshcontrol)'s *auto shrinking and disappearing* behaviour. It includes some haptic feedback ([**UIImpactFeedbackGenerator**](https://developer.apple.com/documentation/uikit/uiimpactfeedbackgenerator)), similar to that of the **refresh control**.

This haptic feedback *is not activated by default* while scrolling across the middle of the list. When you reach the end of the data in the list, enable it by following the below example:

```swift
self.viewModel.load(completion: { [weak self] in
    guard let `self` = self else { return }
    
    /// If you've run out of data, enable 'haptic feedback'.
    self.tableView.loadControl?.isHapticEnabled = self.viewModel.isEnded
    
    DispatchQueue.main.async {
        self.tableView.reloadData()
        self.tableView.loadControl?.endLoading()
    }
})
```

I'm still unsure whether I should give it the ability to adjust the *intensity* of the feedback. Currently, it is the same as the [**UIRefreshControl**](https://developer.apple.com/documentation/uikit/uirefreshcontrol), which has the [**FeedbackStyle**](https://developer.apple.com/documentation/uikit/uiimpactfeedbackgenerator/feedbackstyle) set to `.medium`.

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
.product(name: "LoadControl", package: "LoadControl")
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
The features of **LoadControl** is heavily inspired by, and is a *totally Swifted* alternative of the component [**UIScrollView-InfiniteScroll**](https://github.com/pronebird/UIScrollView-InfiniteScroll) by [Andrej Mihajlov (`pronebird`)](https://github.com/pronebird). Now you don't need the following line in your `Bridging-Header.h` file anymore.

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
