//
//  UIScrollView.swift
//  LoadControl
//
//  Created by Trần T. Dũng on 22/4/24.
//

import UIKit

extension UIScrollView{
    /// The `object association` of the extended <loadControl> property of <UIScrollView>.
    /// A `static property` storing all <loadControl> object `reference addresses`.
    private static let loadControlAssociation = ObjectAssociation<LoadControl>()
    
    /// The `customly extended` <loadControl> property of <UIScrollView>.
    public var loadControl: LoadControl? {
        get { return UIScrollView.loadControlAssociation[self] ?? LoadControl() }
        set {
            UIScrollView.loadControlAssociation[self] = newValue
            UIScrollView.loadControlAssociation[self]?.scrollView = self
        }
    }
}

extension UIScrollView {
    @objc /// This is a `swizzled proxy` method for <setter: self.contentOffset> of <UIScrollView>.
    internal func loadingContentOffset(_ contentOffset: CGPoint) {
        self.loadingContentOffset(contentOffset)
    
        guard let loadControl = self.loadControl, loadControl.isInitialized else { return }
        self.loadingScrollViewDidScroll(with: contentOffset)
    }

    @objc /// This is a `swizzled proxy` method for <setter: self.contentSize> of <UIScrollView>.
    internal func loadingContentSize(_ contentSize: CGSize) {
        self.loadingContentSize(contentSize)

        guard let loadControl = self.loadControl, loadControl.isInitialized else { return }
        self.positionLoadingIndicator(with: contentSize)
    }

    /// Clamp `content size` to fit visible bounds of scroll view.
    /// Visible area is a scroll view size `minus original top and bottom insets for vertical direction`,
    /// or `minus original left and right insets for horizontal direction`.
    ///
    /// - Parameter contentSize: The input content size.
    ///
    /// - Returns: The `minimum content height or width`, calculated using `original insets`.
    ///
    private func clampToFitVisibleBounds(with contentSize: CGSize) -> CGFloat {
        /// Find `minimum content height`. Only original insets are used in calculation.
        switch self.loadControl?.direction {
        case .vertical:
            let minHeight: CGFloat = self.bounds.size.height - self.adjustedContentInset.top - self.originalLoadingEndInset()
            return max(contentSize.height, minHeight)
            
        default:
            let minWidth: CGFloat = self.bounds.size.width - self.adjustedContentInset.left - self.originalLoadingEndInset()
            return max(contentSize.width, minWidth)
        }
    }

    /// Find original `end (bottom or right) inset` without `extra padding & indicator padding`.
    ///
    /// - Returns: The original `end inset (bottom or right)` float value.
    ///
    private func originalLoadingEndInset() -> CGFloat {
        guard let loadControl = self.loadControl else { return 0 }

        switch loadControl.direction {
        case .vertical: return self.adjustedContentInset.bottom - loadControl.extraEndInset - loadControl.indicatorInset
        default: return self.adjustedContentInset.right - loadControl.extraEndInset - loadControl.indicatorInset
        }
    }

    /// `Guaranteed to return` an indicator view.
    ///
    /// - Returns: A `guaranteed loading control` view, created `if needed`.
    ///
    private func wrappedLoadControl() -> LoadControl {
        /// Add `activity indicator` into scroll view `if needed`
        let loadControl = self.loadControl ?? LoadControl()
        if loadControl.superview != self { self.addSubview(loadControl) }
        
        return loadControl
    }

    /// A `row height for indicator` view, in other words: `indicator margin + indicator height`.
    ///
    /// - Returns: The `row height` value of the loading indicator.
    ///
    private func loadingIndicatorRowSize() -> CGFloat {
        let loadControl = self.wrappedLoadControl()

        switch self.loadControl?.direction {
        case .vertical:
            let indicatorHeight: CGFloat = loadControl.bounds.height
            return indicatorHeight + loadControl.indicatorMargin * 2
            
        default:
            let indicatorWidth: CGFloat = loadControl.bounds.height
            return indicatorWidth + loadControl.indicatorMargin * 2
        }
    }

    /// Update `loading indicator's position` in view.
    ///
    /// - Parameter contentSize: The `content size` which the `loading indicator` is positioned at.
    ///
    private func positionLoadingIndicator(with contentSize: CGSize) {
        let loadControl = self.wrappedLoadControl()
        let contentLength: CGFloat = self.clampToFitVisibleBounds(with: contentSize)
        let indicatorRowSize: CGFloat = self.loadingIndicatorRowSize()

        var center: CGPoint
        
        switch self.loadControl?.direction {
        case .vertical: center = CGPoint(x: contentSize.width * 0.5, y: contentLength + indicatorRowSize * 0.5)
        default: center = CGPoint(x: contentLength + indicatorRowSize * 0.5, y: contentSize.height * 0.5)
        }

        if loadControl.center != center { loadControl.center = center }
    }

    /// Update `loading indicator's position` in view.
    ///
    /// - Parameter scrollToBottom: Indicates whether or not the `scroll view`
    ///   should `scroll to bottom` after the loading animation `has started`.
    ///
    internal func beginLoadingIfNeeded(_ scrollToBottom: Bool) {
        let loadControl = self.wrappedLoadControl()
        
        /// `Already` loading?
        if loadControl.isLoading { return }
        
        /// Only `show the loading` if `it is allowed`.
        if loadControl.shouldShowLoadingHandler ?? true {
            self.startLoadingAnimation(scrollToBottom)
            
            /// This will `delay handler execution` until scroll `deceleration`.
            Async.delay(.milliseconds(100)) { self.loadControl?.sendActions(for: .valueChanged) }
        }
    }

    /// `Start animating` loading indicator.
    ///
    /// - Parameter scrollToBottom: Indicates whether or not the `scroll view`
    ///   should `scroll to bottom` after the loading animation `has started`.
    ///
    internal func startLoadingAnimation(_ scrollToBottom: Bool) {
        let loadControl = self.wrappedLoadControl()
        loadControl.activityIndicatorView.startAnimating()
        
        Haptic.medium() /// `Mimic` the behavior of <UIRefreshControl> with a little `impact feedback`.
        
        /// Layout `indicator view`.
        self.positionLoadingIndicator(with: self.contentSize)
        
        /// It's `show time`!
        loadControl.isHidden = false
        if loadControl.responds(to: #selector(UIActivityIndicatorView.startAnimating)) {
            loadControl.perform(#selector(UIActivityIndicatorView.startAnimating))
        }
        
        /// Calculate `indicator view inset`.
        let indicatorInset: CGFloat = self.loadingIndicatorRowSize()
        var contentInset: UIEdgeInsets = self.contentInset
        
        /// Make a room to `accommodate indicator view`.
        switch loadControl.direction {
        case .vertical: contentInset.bottom += indicatorInset
        case .horizontal: contentInset.right += indicatorInset
        }
        
        /// We have to pad scroll view when `content size is smaller than view bounds`.
        /// This will `guarantee` that indicator view appears `at the very end of scroll view`.
        let adjustedContentSize: CGFloat = self.clampToFitVisibleBounds(with: self.contentSize)
        
        /// Add `empty space padding`.
        switch loadControl.direction {
        case .vertical:
            let extraBottomInset: CGFloat = adjustedContentSize - self.contentSize.height
            contentInset.bottom += extraBottomInset
            
            /// Save `extra inset`.
            loadControl.extraEndInset = extraBottomInset
            
        case .horizontal:
            let extraRightInset: CGFloat = adjustedContentSize - self.contentSize.width
            contentInset.right += extraRightInset
            
            /// Save `extra inset`.
            loadControl.extraEndInset = extraRightInset
        }
        
        /// Save `indicator view inset`.
        loadControl.indicatorInset = indicatorInset
        
        /// Update `loading state`.
        loadControl.isLoading = true
        
        /// Scroll to start if `scroll view had no content before update`.
        loadControl.scrollToStartWhenFinished = !loadControl.hasLoadingContent
        
        /// Animate `content insets`.
        self.setLoadingContentInset(contentInset, animated: true, completion: { [weak self] isFinished in
            guard let `self` = self, isFinished else { return }
            
            self.scrollToLoadingIndicatorIfNeeded(shouldReveal: true, scrollToBottom: scrollToBottom)
        })
    }

    /// `Stop animating` loading indicator.
    ///
    /// - Parameter completion: The completion handler, calling back `self` as the super `scroll view`.
    ///
    internal func stopLoadingAnimation(completion: ((UIScrollView) -> Void)?) {
        let loadControl = self.wrappedLoadControl()
        loadControl.activityIndicatorView.stopAnimating()
        
        if let tableView = self as? UITableView { tableView.forceUpdateContentSize() }
        
        var contentInset: UIEdgeInsets = self.contentInset
        
        switch loadControl.direction {
        case .vertical:
            /// Remove `row height inset`.
            contentInset.bottom -= loadControl.indicatorInset
            
            /// Remove `extra inset added to pad loading`.
            contentInset.bottom -= loadControl.extraEndInset
            
        case .horizontal:
            /// Remove `row height inset`.
            contentInset.right -= loadControl.indicatorInset
            
            /// Remove `extra inset added to pad loading`.
            contentInset.right -= loadControl.extraEndInset
        }
        
        /// Reset `extra inset`.
        loadControl.extraEndInset = 0
        
        /// Animate `content insets`
        self.setLoadingContentInset(contentInset, animated: true, completion: { [weak self] isFinished in
            guard let `self` = self else { return }
            
            /// Initiate scroll to the end if due to `user interaction contentOffset`
            /// `stuck somewhere` between `the last cell` and `activity indicator`.
            if isFinished {
                if loadControl.scrollToStartWhenFinished { self.scrollToStart() }
                else { self.scrollToLoadingIndicatorIfNeeded(shouldReveal: false, scrollToBottom: false) }
            }
            
            /// `Curtain is closing` they're throwing roses at my feet.
            loadControl.isHidden = true
            if loadControl.responds(to: #selector(UIActivityIndicatorView.stopAnimating)) {
                loadControl.perform(#selector(UIActivityIndicatorView.stopAnimating))
            }
            
            /// `Reset` scroll state.
            if !self.isDragging { Async.immediately { loadControl.isLoading = false } }
            else { Async.delay(.milliseconds(500)) { loadControl.isLoading = false } }
            
            /// Call `completion handler`.
            completion?(self)
        })
    }

    /// Called whenever `self.contentOffset` changes.
    ///
    /// - Parameter contentOffset: The `updated` content offset.
    ///
    private func loadingScrollViewDidScroll(with contentOffset: CGPoint) {
        if !self.isDragging && !UIAccessibility.isVoiceOverRunning { return } /// Is `user initiated`?

        let loadControl = self.wrappedLoadControl()
        let contentSize: CGFloat = self.clampToFitVisibleBounds(with: self.contentSize)
        
        switch loadControl.direction {
        case .vertical: /// The `lower bound` when loading should kick in.
            var actionOffset = CGPoint(x: 0, y: contentSize - self.bounds.size.height + self.originalLoadingEndInset())
            actionOffset.y -= loadControl.triggerOffset
            
            if contentOffset.y > actionOffset.y &&
                self.panGestureRecognizer.velocity(in: self).y <= 0 { self.beginLoadingIfNeeded(false) }
            
        case .horizontal: /// The `lower bound` when loading should kick in.
            var actionOffset = CGPoint(x: contentSize - self.bounds.size.width + self.originalLoadingEndInset(), y: 0)
            actionOffset.x -= loadControl.triggerOffset
            
            if contentOffset.x > actionOffset.x &&
                self.panGestureRecognizer.velocity(in: self).x <= 0 { self.beginLoadingIfNeeded(false) }
        }
    }

    /// Scrolls view `to start`.
    ///
    private func scrollToStart() {
        var contentOffset: CGPoint = .zero
        
        switch self.loadControl?.direction {
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

    /// Scrolls to activity indicator if it is `partially visible`.
    ///
    /// - Parameters:
    ///   - shouldReveal: Scroll to reveal or hide activity indicator.
    ///   - scrollToBottom: Forces scroll to bottom.
    ///
    internal func scrollToLoadingIndicatorIfNeeded(shouldReveal: Bool, scrollToBottom: Bool) {
        guard !self.isDragging else { return } /// `Do not interfere` with the user.

        /// `Filter out` calls from the `pan gesture`.
        guard let loadControl = self.loadControl, loadControl.isLoading else { return }
        
        /// `Force` the table view to update it's `content size`.
        if let tableView = self as? UITableView { tableView.forceUpdateContentSize() }
        
        let contentSize: CGFloat = self.clampToFitVisibleBounds(with: self.contentSize)
        let indicatorRowSize: CGFloat = self.loadingIndicatorRowSize()
        
        switch loadControl.direction {
        case .vertical:
            let minY: CGFloat = contentSize - self.bounds.size.height + self.originalLoadingEndInset()
            let maxY: CGFloat = minY + indicatorRowSize
            
            guard (self.contentOffset.y > minY && self.contentOffset.y < maxY) || scrollToBottom else { return }
            self.contentOffset = CGPoint(x: self.contentOffset.x, y: shouldReveal ? maxY : minY)
                
            /// Use <scrollToRow(at:)> in case of <UITableView>.
            /// Because <setContentOffset(_:)> may `not work properly` when using `self-sizing` cells.
            guard let tableView = self as? UITableView else { return }
            
            let lastSection: Int = tableView.numberOfSections - 1
            let numberOfRows: Int = lastSection >= 0 ? tableView.numberOfRows(inSection: lastSection) : 0
            let lastRow: Int = numberOfRows - 1
            
            guard lastSection >= 0 && lastRow >= 0 else { return }
            
            let indexPath = IndexPath(row: lastRow, section: lastSection)
            tableView.scrollToRow(at: indexPath, at: shouldReveal ? .top : .bottom, animated: true)
            
        case .horizontal:
            let minX: CGFloat = contentSize - self.bounds.size.width + self.originalLoadingEndInset()
            let maxX: CGFloat = minX + indicatorRowSize
            
            guard (self.contentOffset.x > minX && self.contentOffset.x < maxX) || scrollToBottom else { return }
            self.contentOffset = CGPoint(x: shouldReveal ? maxX : minX, y: self.contentOffset.y)
        }
    }
    
    /// Set the scroll view with an `updated content inset` value, whether it's `animated or not`.
    ///
    /// - Parameters:
    ///   - contentInset: The new content inset value.
    ///   - animated: A flag determines whether or not the changes in the loading content inset should be animated.
    ///   - completion: The completion handler.
    ///
    private func setLoadingContentInset(_ contentInset: UIEdgeInsets, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        let animations: () -> Void = { self.contentInset = contentInset }

        if animated {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.beginFromCurrentState],
                           animations: animations, completion: completion)
        } else {
            UIView.performWithoutAnimation(animations)
            completion?(true)
        }
    }
}
