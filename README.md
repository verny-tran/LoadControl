<br />
<p align="center" width="100%">
    <img width="15%" src="https://github.com/verny-tran/LoadControl/blob/main/Resources/Icons/LoadControl.png"> 
</p>
<h1 align="center"> LoadControl </h1>

A standard control that can initiate the loading of a scroll view’s contents.

[![CI Status](https://img.shields.io/travis/verny-tran/LoadControl}.svg?style=flat)](https://travis-ci.org/verny-tran/LoadControl})
[![Version](https://img.shields.io/cocoapods/v/LoadControl.svg?style=flat)](https://cocoapods.org/pods/LoadControl)
[![License](https://img.shields.io/cocoapods/l/LoadControl.svg?style=flat)](https://cocoapods.org/pods/LoadControl)
[![Platform](https://img.shields.io/cocoapods/p/LoadControl.svg?style=flat)](https://cocoapods.org/pods/LoadControl)

## Features

### LoadControl 101

The simplest use-case is adding an action selector to a target with the [UIScrollView](https://developer.apple.com/documentation/uikit/uiscrollview) extension:

```swift
import LoadControl

self.tableView.loadControl = LoadControl()
self.tableView.loadControl?.addTarget(self, action: #selector(load), for: .valueChanged)

@objc
private func load()
```

Similar to that of the [UIRefreshControl](https://developer.apple.com/documentation/uikit/uirefreshcontrol):
```swift
self.tableView.refreshControl = UIRefreshControl()
self.tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

@objc
private func refresh()
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

**CocoaPods** `1.0.0+`

## Installation

**LoadControl** is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your `Podfile`:

```ruby
pod 'LoadControl'
```

## Authors

[Trần T. Dũng](https://github.com/verny-tran) (Verny), vernytran@icloud.com

[Võ C. Kha](https://github.com/zachvoxwatt) (Zach), khavo0704@gmail.com

## License

**LoadControl** is available under the **MIT** license. See the `LICENSE` file for more info.
