//
//  LoadControl.swift
//  LoadControl
//
//  Created by Trần T. Dũng on 21/4/24.
//

import Foundation
import UIKit

/// Animation duration used for <setContentOffset:>
let loadingAnimationDuration: TimeInterval = 0.5

/// Keys for values in `associated dictionary`
let loadingStateKey: UnsafeRawPointer = loadingStateKey

@MainActor
public class LoadControl : UIControl {
    /// Loading `direction`, horizontal for <UICollectionView>.
    public enum Direction {
        case vertical
        case horizontal
    }
    
    /// The `parent scroll view` of the infinite <LoadControl>.
    weak public var scrollView: UIScrollView?
    
    /// A flag that indicates whether loading `is in progress`.
    public var isLoading: Bool = false
    
    /// A flag that indicates whether the control `is initialized`
    internal var isInitialized: Bool = false
    
    /// The `activity Indicator` view.
    internal let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        return activityIndicatorView
    }()

    /// Indicator view margin: `top & bottom for vertical` direction
    /// or `left & right for horizontal` direction.
    private var loadingIndicatorMargin: CGFloat = 25
    public var indicatorMargin: CGFloat {
        get { return self.loadingIndicatorMargin }
        set { self.loadingIndicatorMargin = newValue }
    }
    
    /// The `direction` that the infinite scroll is working in.
    private var loadingDirection: LoadControl.Direction = .vertical
    public var direction: LoadControl.Direction {
        get { return self.loadingDirection }
        set { self.loadingDirection = newValue }
    }
    
    /// Indicator view inset. Essentially `is equal to indicator view height`.
    public var indicatorInset: CGFloat = 50
    
    /// `Extra padding` to push indicator view outside view bounds.
    /// Used in case `when content size` is `smaller than view bounds`.
    public var extraEndInset: CGFloat = 0
    
    /// The`triggering content offset`.
    public var triggerOffset: CGFloat = 0
    
    /// Flag `used to return user back to start` of scroll view when loading initial content.
    public var scrollToStartWhenFinished: Bool = false
    
    /// Infinite scroll `allowed block`.
    /// Return ``false`` to `block the infinite scroll`.
    /// Useful to `stop requests` when you have `shown all results`, etc.
    public var shouldShowLoadingHandler: Bool?
    
    /// Checks if `UIScrollView is empty`.
    internal var hasLoadingContent: Bool {
        var constant: CGFloat = 0 /// Default `UITableView` reports height = 1 on empty tables
        if self.scrollView is UITableView { constant = 1 }

        switch self.direction {
        case .vertical: return self.scrollView?.contentSize.height ?? 0 > constant
        default: return self.scrollView?.contentSize.width ?? 0 > constant
        }
    }
    
    /// The designated `initializer`. This initializes a <LoadingControl> with a default height and width.
    /// Once assigned to a <UITableViewController>, the frame of the control is `managed automatically`.
    /// When a user has `scroll-to-load-more`, the <LoadingControl> fires it's <UIControlEventValueChanged> event.
    ///
    public init() {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.size.width, height: 44)))
        
        if !UIScrollView.isSwizzled { UIScrollView.swizzle }
        self.addSubview(self.activityIndicatorView)
        
        self.activityIndicatorView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        self.activityIndicatorView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        self.activityIndicatorView.constraint(to: self, anchor: .centerX, pivot: .centerX)
        self.activityIndicatorView.constraint(to: self, anchor: .centerY, pivot: .centerY)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        super.addTarget(target, action: action, for: controlEvents)
        
        guard controlEvents == .valueChanged else { return }
        
        /// `Double initialization` only replaces handler block.
        /// Do not continue if `already initialized`.
        if self.isInitialized { return }
        
        /// Add `pan gesture` handler.
        self.scrollView?.panGestureRecognizer.addTarget(self, action: #selector(self.handleGesture(_:)))
        
        /// Mark loadingScroll `initialized`.
        self.isInitialized = true
    }
    
    /// May be used to indicate to the `refreshControl` that an `external event` has initiated the `loading action`.
    ///
    public func beginLoading() {
        self.scrollView?.beginLoadingIfNeeded(true)
    }

    /// Must be explicitly `called when the refreshing has completed`.
    ///
    public func endLoading() {
        guard self.isLoading else { return }
        
        Async.delay(.milliseconds(500)) { self.scrollView?.stopLoadingAnimation(completion: nil) }
    }
    
    /// Must be explicitly `called when the refreshing has removed`.
    ///
    public func removeLoading() {
        /// `Ignore multiple calls` to remove loading.
        if !self.isInitialized { return }
        
        /// `Remove` pan gesture handler.
        self.scrollView?.panGestureRecognizer.removeTarget(self, action: #selector(handleGesture(_:)))
        
        /// `Destroy` loading indicator.
        self.activityIndicatorView.removeFromSuperview()
        
        /// Mark loading `as uninitialized`.
        self.isInitialized = false
    }
    
    @objc
    /// `Additional pan gesture handler` used to adjust content offset to reveal or hide indicator view.
    ///
    /// - Parameter recognizer: The sender tap gesture recognizer.
    ///
    private func handleGesture(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed {
            self.scrollView?.scrollToLoadingIndicatorIfNeeded(shouldReveal: true, scrollToBottom: false)
        }
    }
}
