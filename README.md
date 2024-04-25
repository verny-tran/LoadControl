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

## Installation

**LoadControl** is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your `Podfile`:

```ruby
pod 'LoadControl'
```

## Author

Trần T. Dũng, vernytran@icloud.com

## License

**LoadControl** is available under the **MIT** license. See the `LICENSE` file for more info.

<!--pod-template-->
<!--============-->
<!---->
<!--An opinionated template for creating a Pod with the following features:-->
<!---->
<!--- Git as the source control management system-->
<!--- Clean folder structure-->
<!--- Project generation-->
<!--- MIT license-->
<!--- Testing as a standard-->
<!--- Turnkey access to Travis CI-->
<!--- Also supports Carthage-->
<!---->
<!--## Getting started-->
<!---->
<!--There are two reasons for wanting to work on this template, making your own or improving the one for everyone's. In both cases you will want to work with the ruby classes inside the `setup` folder, and the example base template that it works on from inside `template/ios/`. -->
<!---->
<!--## Best practices-->
<!---->
<!--The command `pod lib create` aims to be ran along with this guide: https://guides.cocoapods.org/making/using-pod-lib-create.html so any changes of flow should be updated there also.-->
<!---->
<!--It is open to communal input, but adding new features, or new ideas are probably better off being discussed in an issue first. In general we try to think if an average Xcode user is going to use this feature or not, if it's unlikely is it a _very strongly_ encouraged best practice ( ala testing / CI. ) If it's something useful for saving a few minutes every deploy, or isn't easily documented in the guide it is likely to be denied in order to keep this project as simple as possible.-->
<!---->
<!--## Requirements:-->
<!---->
<!--- CocoaPods 1.0.0+-->
