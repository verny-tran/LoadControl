//
//  LoadControl.swift
//  LoadControl
//
//  Created by Trần T. Dũng on 21/4/24.
//

import Foundation
import UIKit
import Lottie

/// Animation duration used for <setContentOffset:>
let loadingAnimationDuration: TimeInterval = 0.5

/// Keys for values in `associated dictionary`
let loadingStateKey: UnsafeRawPointer = loadingStateKey

@MainActor
final public class LoadingControl: UIControl {
    public enum Direction: UInt {
        case vertical
        case horizontal
    }
    
    /// `Infinite Loading` scroll view
    weak public var scrollView: UIScrollView?
    
    /// A flag that indicates whether the control `is initialized`
    fileprivate var isInitialized: Bool = false
    
    /// A flag that indicates whether loading `is in progress`.
    public var isLoading: Bool = false
    
    /// `Indicator view`.
    fileprivate let animation: LottieAnimationView = {
        let lottieView = LottieAnimationView(name: "loading")
        lottieView.loopMode = .loop
        lottieView.alpha = 0.5
        lottieView.backgroundColor = .clear
        lottieView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        return lottieView
    }()

    /// Indicator view margin: `top & bottom for vertical` direction
    /// or `left & right for horizontal` direction.
    private var loadingIndicatorMargin: CGFloat = 25
    public var indicatorMargin: CGFloat {
        get { return self.loadingIndicatorMargin }
        set { self.loadingIndicatorMargin = newValue }
    }
    
    /// The `direction` that the infinite scroll is working in.
    private var loadingDirection: LoadingControl.Direction = .vertical
    public var direction: LoadingControl.Direction {
        get { return self.loadingDirection }
        set { self.loadingDirection = newValue }
    }
    
    /// Indicator view inset. Essentially `is equal to indicator view height`.
    public var indicatorInset: CGFloat = 50
    
    /// `Extra padding` to push indicator view outside view bounds.
    /// Used in case when content size is smaller than view bounds
    public var extraEndInset: CGFloat = 0
    
    /// `Trigger offset`.
    public var triggerOffset: CGFloat = 0
    
    /// Flag `used to return user back to start` of scroll view when loading initial content.
    public var scrollToStartWhenFinished: Bool = false

    /// Infinite loading `scroll handler block`
    public var loadingHandler: (() -> Void)?
    
    /// Infinite scroll allowed block
    /// Return `FALSE` to block the infinite scroll.
    /// Useful to stop requests when you have shown all results, etc.
    public var shouldShowLoadingHandler: (() -> Bool)?
    
    /// Checks if `UIScrollView is empty`.
    fileprivate var hasLoadingContent: Bool {
        var constant: CGFloat = 0 /// Default `UITableView` reports height = 1 on empty tables
        if self.scrollView is UITableView { constant = 1 }

        switch self.direction {
        case .vertical: return self.scrollView?.contentSize.height ?? 0 > constant
        default: return self.scrollView?.contentSize.width ?? 0 > constant
        }
    }

    /// The designated initializer
    /// This initializes a `LoadingControl` with a default height and width.
    /// Once assigned to a `UITableViewController`, the frame of the control is managed automatically.
    /// When a user has scroll-to-load-more, the `LoadingControl` fires its `UIControlEventValueChanged` event.
    override init(frame: CGRect = CGRect(center: .zero, size: CGSize(width: Screen.width, height: 50))) {
        super.init(frame: frame)
        self.addSubview(self.animation)
        
        self.animation.widthAnchor.constraint(equalToConstant: 60).isActive = true
        self.animation.heightAnchor.constraint(equalToConstant: 60).isActive = true
        self.animation.constraint(to: self, anchor: .centerX, pivot: .centerX)
        self.animation.constraint(to: self, anchor: .centerY, pivot: .centerY)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addAction(_ action: @escaping () -> Void) {
        /// `Save` handler block
        self.loadingHandler = action
        
        /// `Double initialization` only replaces handler block
        /// Do not continue if `already initialized`
        if self.isInitialized { return }
        
        /// Add `pan gesture` handler
        let handler = #selector(self.handleLoadingGesture(_:))
        self.scrollView?.panGestureRecognizer.addTarget(self, action: handler)
        
        /// Mark loadingScroll `initialized`
        self.isInitialized = true
    }
    
    /// May be used to indicate to the `refreshControl` that an external event has initiated the refresh action
    public func beginLoading() {
        self.scrollView?.beginLoadingIfNeeded(true)
    }

    /// Must be explicitly `called when the refreshing has completed`
    public func endLoading() {
        if self.isLoading { Async.delay(.milliseconds(500)) {
            self.scrollView?.stopLoadingAnimation(completion: nil)
        } }
    }
    
    /// Must be explicitly `called when the refreshing has removed`
    public func removeLoading() {
        /// `Ignore multiple calls` to remove loading
        if !self.isInitialized { return }
        
        /// `Remove` pan gesture handler
        let handler = #selector(self.handleLoadingGesture(_:))
        self.scrollView?.panGestureRecognizer.removeTarget(self, action: handler)
        
        /// `Destroy` loading indicator
        self.animation.removeFromSuperview()
        
        /// `Release` handler block
        self.loadingHandler = nil
        
        /// Mark loading `as uninitialized`
        self.isInitialized = false
    }
    
    @objc /// `Additional pan gesture handler` used to adjust content offset to reveal or hide indicator view.
    private func handleLoadingGesture(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed {
            self.scrollView?.scrollToLoadingIndicatorIfNeeded(reveal: true, force: false)
        }
    }
}

extension UIScrollView {
    @objc /// This is a `swizzled proxy` method for <setter: self.contentOffset> of UIScrollView.
    func loadingContentOffset(_ contentOffset: CGPoint) {
        self.loadingContentOffset(contentOffset)
    
        guard let loadingControl = self.loadingControl, loadingControl.isInitialized else { return }
        self.loadingScrollViewDidScroll(with: contentOffset)
    }

    @objc /// This is a `swizzled proxy` method for <setter: self.contentSize> of UIScrollView.
    func loadingContentSize(_ contentSize: CGSize) {
        self.loadingContentSize(contentSize)

        guard let loadingControl = self.loadingControl, loadingControl.isInitialized else { return }
        self.positionLoadingIndicator(with: contentSize)
    }

    /// Clamp `content size` to fit visible bounds of scroll view.
    /// Visible area is a scroll view size `minus original top and bottom insets for vertical direction`,
    /// or `minus original left and right insets for horizontal direction`.
    fileprivate func clampToFitVisibleBounds(with contentSize: CGSize) -> CGFloat {
        let adjustedContentInset: UIEdgeInsets = self.adjustedContentInset

        /// Find `minimum content height`. Only original insets are used in calculation.
        switch self.loadingControl?.direction {
        case .vertical:
            let minHeight: CGFloat = self.bounds.size.height - adjustedContentInset.top - self.originalLoadingEndInset()
            return max(contentSize.height, minHeight)
        default:
            let minWidth: CGFloat = self.bounds.size.width - adjustedContentInset.left - self.originalLoadingEndInset()
            return max(contentSize.width, minWidth)
        }
    }

    /// Returns `end (bottom or right) inset` without `extra padding & indicator padding`.
    fileprivate func originalLoadingEndInset() -> CGFloat {
        let adjustedContentInset: UIEdgeInsets = self.adjustedContentInset
        if let loadingControl = self.loadingControl {
            switch loadingControl.direction {
            case .vertical: return adjustedContentInset.bottom - loadingControl.extraEndInset - loadingControl.indicatorInset
            default: return adjustedContentInset.right - loadingControl.extraEndInset - loadingControl.indicatorInset
            }
        }
        return 0
    }

    /// `Guaranteed to return` an indicator view.
    fileprivate func loadingView() -> UIView {
        
        /// Add activity indicator into scroll view `if needed`
        if self.loadingControl?.superview != self { self.addSubview(self.loadingControl ?? LoadingControl()) }
        return self.loadingControl ?? LoadingControl()
    }

    /// A `row height for indicator` view, in other words: `indicator margin + indicator height`.
    fileprivate func loadingIndicatorRowSize() -> CGFloat {
        let loadingView = self.loadingView()

        switch self.loadingControl?.direction {
        case .vertical:
            let indicatorHeight: CGFloat = loadingView.bounds.height
            return indicatorHeight + (self.loadingControl?.indicatorMargin ?? 0) * 2
        default:
            let indicatorWidth: CGFloat = loadingView.bounds.height
            return indicatorWidth + (self.loadingControl?.indicatorMargin ?? 0) * 2
        }
    }

    /// Update `loading indicator's position` in view.
    fileprivate func positionLoadingIndicator(with contentSize: CGSize) {
        let loadingView = self.loadingView()
        let contentLength: CGFloat = self.clampToFitVisibleBounds(with: contentSize)
        let indicatorRowSize: CGFloat = self.loadingIndicatorRowSize()

        var center: CGPoint
        
        switch self.loadingControl?.direction {
        case .vertical: center = CGPoint(x: contentSize.width * 0.5, y: contentLength + indicatorRowSize * 0.5)
        default: center = CGPoint(x: contentLength + indicatorRowSize * 0.5, y: contentSize.height * 0.5)
        }

        if loadingView.center != center { loadingView.center = center }
    }

    /// Update `loading indicator's position` in view.
    fileprivate func beginLoadingIfNeeded(_ forceScroll: Bool) {
        if let loadingControl = self.loadingControl {
            
            /// `Already loading?`
            if loadingControl.isLoading { return }
            
            /// Only `show the loading if it is allowed`
            if loadingControl.shouldShowLoadingHandler?() ?? true {
                self.startLoadingAnimation(forceScroll)
                
                /// This will `delay handler execution` until scroll deceleration
                Async.delay(.milliseconds(100)) { loadingControl.loadingHandler?() }
            }
        }
    }

    /// `Start animating` loading indicator
    fileprivate func startLoadingAnimation(_ forceScroll: Bool) {
        if let loadingControl = self.loadingControl {
            let loadingView = self.loadingView()
            
            loadingControl.animation.play()
            
            /// Layout `indicator view`
            self.positionLoadingIndicator(with: self.contentSize)
            
            /// It's show time!
            loadingView.isHidden = false
            if loadingView.responds(to: #selector(UIActivityIndicatorView.startAnimating)) {
                loadingView.perform(#selector(UIActivityIndicatorView.startAnimating))
            }
            
            /// Calculate `indicator view inset`
            let indicatorInset: CGFloat = self.loadingIndicatorRowSize()
            var contentInset: UIEdgeInsets = self.contentInset
            
            /// Make a room to `accommodate indicator view`
            switch loadingControl.direction {
            case .vertical: contentInset.bottom += indicatorInset
            case .horizontal: contentInset.right += indicatorInset
            }
            
            /// We have to pad scroll view when `content size is smaller than view bounds`.
            /// This will guarantee that indicator view appears `at the very end of scroll view`.
            let adjustedContentSize: CGFloat = self.clampToFitVisibleBounds(with: self.contentSize)
            
            /// Add `empty space padding`
            switch loadingControl.direction {
            case .vertical:
                let extraBottomInset: CGFloat = adjustedContentSize - self.contentSize.height
                contentInset.bottom += extraBottomInset
                
                /// Save `extra inset`
                loadingControl.extraEndInset = extraBottomInset
                
            case .horizontal:
                let extraRightInset: CGFloat = adjustedContentSize - self.contentSize.width
                contentInset.right += extraRightInset
                
                /// Save `extra inset`
                loadingControl.extraEndInset = extraRightInset
            }
            
            /// Save `indicator view inset`
            loadingControl.indicatorInset = indicatorInset
            
            /// Update `loading state`
            loadingControl.isLoading = true
            
            /// Scroll to start if `scroll view had no content before update`
            loadingControl.scrollToStartWhenFinished = !loadingControl.hasLoadingContent
            
            /// Animate `content insets`
            self.setLoadingContentInset(contentInset, animated: true, completion: { finished in
                if finished { self.scrollToLoadingIndicatorIfNeeded(reveal: true, force: forceScroll) }
            })
        }
    }

    /// `Stop animating` loading indicator
    fileprivate func stopLoadingAnimation(completion: ((UIScrollView) -> Void)?) {
        if let loadingControl = self.loadingControl {
            let loadingView = self.loadingView()
            
            loadingControl.animation.stop()
            
            var contentInset: UIEdgeInsets = self.contentInset
            if let tableView = self as? UITableView { tableView.forceUpdateContentSize() }
            
            switch loadingControl.direction {
            case .vertical:
                /// Remove `row height inset`
                contentInset.bottom -= loadingControl.indicatorInset
                
                /// Remove `extra inset added to pad loading`
                contentInset.bottom -= loadingControl.extraEndInset
                
            case .horizontal:
                /// Remove `row height inset`
                contentInset.right -= loadingControl.indicatorInset
                
                /// Remove `extra inset added to pad loading`
                contentInset.right -= loadingControl.extraEndInset
            }
            
            /// Reset `extra inset`
            loadingControl.extraEndInset = 0
            
            /// Animate `content insets`
            self.setLoadingContentInset(contentInset, animated: true, completion: { finished in
                /// Initiate scroll to the end if due to `user interaction contentOffset`
                /// `stuck somewhere` between the last cell and activity indicator
                if finished {
                    if loadingControl.scrollToStartWhenFinished { self.scrollToStart() }
                    else { self.scrollToLoadingIndicatorIfNeeded(reveal: false, force: false) }
                }
                
                /// `Curtain is closing` they're throwing roses at my feet
                loadingView.isHidden = true
                if loadingView.responds(to: #selector(UIActivityIndicatorView.stopAnimating)) {
                    loadingView.perform(#selector(UIActivityIndicatorView.stopAnimating))
                }
                
                /// `Reset` scroll state
                if !self.isDragging { Async.immediately { loadingControl.isLoading = false } }
                else { Async.delay(.milliseconds(500)) { loadingControl.isLoading = false } }
                
                /// Call `completion handler`
                completion?(self)
            })
        }
    }

    /// Called whenever `self.contentOffset` changes.
    fileprivate func loadingScrollViewDidScroll(with contentOffset: CGPoint) {
        /// Is `user initiated?`
        if !self.isDragging && !UIAccessibility.isVoiceOverRunning { return }

        if let loadingControl = self.loadingControl {
            let contentSize: CGFloat = self.clampToFitVisibleBounds(with: self.contentSize)
            
            switch loadingControl.direction {
                
            case .vertical: /// The `lower bound` when loading should kick in
                var actionOffset = CGPoint(x: 0, y: contentSize - self.bounds.size.height + self.originalLoadingEndInset())
                actionOffset.y -= loadingControl.triggerOffset
                
                if contentOffset.y > actionOffset.y &&
                    self.panGestureRecognizer.velocity(in: self).y <= 0 { self.beginLoadingIfNeeded(false) }
                
            case .horizontal: /// The `lower bound` when loading should kick in
                var actionOffset = CGPoint(x: contentSize - self.bounds.size.width + self.originalLoadingEndInset(), y: 0)
                actionOffset.x -= loadingControl.triggerOffset
                
                if contentOffset.x > actionOffset.x &&
                    self.panGestureRecognizer.velocity(in: self).x <= 0 { self.beginLoadingIfNeeded(false) }
            }
        }
    }

    /// Scrolls view `to start`
    fileprivate func scrollToStart() {
        var contentOffset: CGPoint = .zero
        
        switch self.loadingControl?.direction {
        case .vertical:
            contentOffset.x = self.contentOffset.x
            contentOffset.y = self.adjustedContentInset.top * -1
        case .horizontal:
            contentOffset.x = self.adjustedContentInset.left * -1
            contentOffset.y = self.contentOffset.y
        default: break
        }
        
        self.contentOffset = contentOffset
    }

    /// Scrolls to activity indicator if it is `partially visible`
    /// - Parameters:
    ///  - reveal scroll to reveal or hide activity indicator
    ///  - force forces scroll to bottom
    fileprivate func scrollToLoadingIndicatorIfNeeded(reveal: Bool, force: Bool) {
        /// Do not interfere with user
        if self.isDragging { return }

        if let loadingControl = self.loadingControl {
            /// Filter out calls from pan gesture
            if !loadingControl.isLoading { return }
            
            /// Force table view to update content size
            if let tableView = self as? UITableView { tableView.forceUpdateContentSize() }
            
            let contentSize: CGFloat = self.clampToFitVisibleBounds(with: self.contentSize)
            let indicatorRowSize: CGFloat = self.loadingIndicatorRowSize()
            
            switch loadingControl.direction {
            case .vertical:
                let minY: CGFloat = contentSize - self.bounds.size.height + self.originalLoadingEndInset()
                let maxY: CGFloat = minY + indicatorRowSize
                
                if (self.contentOffset.y > minY && self.contentOffset.y < maxY) || force {
                    
                    /// Use `-scrollToRowAtIndexPath:` in case of <UITableView>
                    /// Because `-setContentOffset:` may not work properly when using self-sizing cells
                    if let tableView = self as? UITableView {
                        let lastSection: Int = tableView.numberOfSections - 1
                        let numberOfRows: Int = lastSection >= 0 ? tableView.numberOfRows(inSection: lastSection) : 0
                        let lastRow: Int = numberOfRows - 1
                        
                        if lastSection >= 0 && lastRow >= 0 {
                            let indexPath = IndexPath(row: lastRow, section: lastSection)
                            tableView.scrollToRow(at: indexPath, at: reveal ? .top : .bottom, animated: true)
                            return
                        }
                    }
                    
                    self.contentOffset = CGPoint(x: self.contentOffset.x, y: reveal ? maxY : minY)
                }
            case .horizontal:
                let minX: CGFloat = contentSize - self.bounds.size.width + self.originalLoadingEndInset()
                let maxX: CGFloat = minX + indicatorRowSize
                
                if (self.contentOffset.x > minX && self.contentOffset.x < maxX) || force {
                    self.contentOffset = CGPoint(x: reveal ? maxX : minX, y: self.contentOffset.y)
                }
            }
        }
    }

    fileprivate func setLoadingContentInset(_ contentInset: UIEdgeInsets, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        let animations: () -> Void = { self.contentInset = contentInset }

        if animated {
            UIView.animate(withDuration: 0.25, delay: 0.0,
                           options: [.beginFromCurrentState],
                           animations: animations, completion: completion)
        } else {
            UIView.performWithoutAnimation(animations)
            completion?(true)
        }
    }
}
