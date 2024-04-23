//
//  UIScrollView.swift
//  LoadControl
//
//  Created by Trần T. Dũng on 22/4/24.
//

import UIKit

extension UIScrollView{
    static private let loadControlAssociation = ObjectAssociation<LoadControl>()
    public var loadControl: LoadControl? {
        get { return UIScrollView.loadControlAssociation[self] ?? LoadControl() }
        set {
            UIScrollView.loadControlAssociation[self] = newValue
            UIScrollView.loadControlAssociation[self]?.scrollView = self
        }
    }
}

extension UIScrollView {
    @objc /// This is a `swizzled proxy` method for <setter: self.contentOffset> of UIScrollView.
    internal func loadingContentOffset(_ contentOffset: CGPoint) {
        self.loadingContentOffset(contentOffset)
    
        guard let loadControl = self.loadControl, loadControl.isInitialized else { return }
        self.loadingScrollViewDidScroll(with: contentOffset)
    }

    @objc /// This is a `swizzled proxy` method for <setter: self.contentSize> of UIScrollView.
    internal func loadingContentSize(_ contentSize: CGSize) {
        self.loadingContentSize(contentSize)

        guard let loadControl = self.loadControl, loadControl.isInitialized else { return }
        self.positionLoadingIndicator(with: contentSize)
    }

    /// Clamp `content size` to fit visible bounds of scroll view.
    /// Visible area is a scroll view size `minus original top and bottom insets for vertical direction`,
    /// or `minus original left and right insets for horizontal direction`.
    fileprivate func clampToFitVisibleBounds(with contentSize: CGSize) -> CGFloat {
        let adjustedContentInset: UIEdgeInsets = self.adjustedContentInset

        /// Find `minimum content height`. Only original insets are used in calculation.
        switch self.loadControl?.direction {
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
        if let loadControl = self.loadControl {
            switch loadControl.direction {
            case .vertical: return adjustedContentInset.bottom - loadControl.extraEndInset - loadControl.indicatorInset
            default: return adjustedContentInset.right - loadControl.extraEndInset - loadControl.indicatorInset
            }
        }
        return 0
    }

    /// `Guaranteed to return` an indicator view.
    fileprivate func loadingView() -> UIView {
        
        /// Add activity indicator into scroll view `if needed`
        if self.loadControl?.superview != self { self.addSubview(self.loadControl ?? LoadControl()) }
        return self.loadControl ?? LoadControl()
    }

    /// A `row height for indicator` view, in other words: `indicator margin + indicator height`.
    fileprivate func loadingIndicatorRowSize() -> CGFloat {
        let loadingView = self.loadingView()

        switch self.loadControl?.direction {
        case .vertical:
            let indicatorHeight: CGFloat = loadingView.bounds.height
            return indicatorHeight + (self.loadControl?.indicatorMargin ?? 0) * 2
        default:
            let indicatorWidth: CGFloat = loadingView.bounds.height
            return indicatorWidth + (self.loadControl?.indicatorMargin ?? 0) * 2
        }
    }

    /// Update `loading indicator's position` in view.
    fileprivate func positionLoadingIndicator(with contentSize: CGSize) {
        let loadingView = self.loadingView()
        let contentLength: CGFloat = self.clampToFitVisibleBounds(with: contentSize)
        let indicatorRowSize: CGFloat = self.loadingIndicatorRowSize()

        var center: CGPoint
        
        switch self.loadControl?.direction {
        case .vertical: center = CGPoint(x: contentSize.width * 0.5, y: contentLength + indicatorRowSize * 0.5)
        default: center = CGPoint(x: contentLength + indicatorRowSize * 0.5, y: contentSize.height * 0.5)
        }

        if loadingView.center != center { loadingView.center = center }
    }

    /// Update `loading indicator's position` in view.
    internal func beginLoadingIfNeeded(_ forceScroll: Bool) {
        if let loadControl = self.loadControl {
            
            /// `Already loading?`
            if loadControl.isLoading { return }
            
            /// Only `show the loading if it is allowed`
            if loadControl.shouldShowLoadingHandler?() ?? true {
                self.startLoadingAnimation(forceScroll)
                
                /// This will `delay handler execution` until scroll deceleration
                Async.delay(.milliseconds(100)) { loadControl.loadingHandler?() }
            }
        }
    }

    /// `Start animating` loading indicator
    internal func startLoadingAnimation(_ forceScroll: Bool) {
        if let loadControl = self.loadControl {
            let loadingView = self.loadingView()
            
            loadControl.activityIndicatorView.startAnimating()
            
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
            switch loadControl.direction {
            case .vertical: contentInset.bottom += indicatorInset
            case .horizontal: contentInset.right += indicatorInset
            }
            
            /// We have to pad scroll view when `content size is smaller than view bounds`.
            /// This will guarantee that indicator view appears `at the very end of scroll view`.
            let adjustedContentSize: CGFloat = self.clampToFitVisibleBounds(with: self.contentSize)
            
            /// Add `empty space padding`
            switch loadControl.direction {
            case .vertical:
                let extraBottomInset: CGFloat = adjustedContentSize - self.contentSize.height
                contentInset.bottom += extraBottomInset
                
                /// Save `extra inset`
                loadControl.extraEndInset = extraBottomInset
                
            case .horizontal:
                let extraRightInset: CGFloat = adjustedContentSize - self.contentSize.width
                contentInset.right += extraRightInset
                
                /// Save `extra inset`
                loadControl.extraEndInset = extraRightInset
            }
            
            /// Save `indicator view inset`
            loadControl.indicatorInset = indicatorInset
            
            /// Update `loading state`
            loadControl.isLoading = true
            
            /// Scroll to start if `scroll view had no content before update`
            loadControl.scrollToStartWhenFinished = !loadControl.hasLoadingContent
            
            /// Animate `content insets`
            self.setLoadingContentInset(contentInset, animated: true, completion: { finished in
                if finished { self.scrollToLoadingIndicatorIfNeeded(reveal: true, force: forceScroll) }
            })
        }
    }

    /// `Stop animating` loading indicator
    internal func stopLoadingAnimation(completion: ((UIScrollView) -> Void)?) {
        if let loadControl = self.loadControl {
            let loadingView = self.loadingView()
            
            loadControl.activityIndicatorView.stopAnimating()
            
            var contentInset: UIEdgeInsets = self.contentInset
            if let tableView = self as? UITableView { tableView.forceUpdateContentSize() }
            
            switch loadControl.direction {
            case .vertical:
                /// Remove `row height inset`
                contentInset.bottom -= loadControl.indicatorInset
                
                /// Remove `extra inset added to pad loading`
                contentInset.bottom -= loadControl.extraEndInset
                
            case .horizontal:
                /// Remove `row height inset`
                contentInset.right -= loadControl.indicatorInset
                
                /// Remove `extra inset added to pad loading`
                contentInset.right -= loadControl.extraEndInset
            }
            
            /// Reset `extra inset`
            loadControl.extraEndInset = 0
            
            /// Animate `content insets`
            self.setLoadingContentInset(contentInset, animated: true, completion: { finished in
                /// Initiate scroll to the end if due to `user interaction contentOffset`
                /// `stuck somewhere` between the last cell and activity indicator
                if finished {
                    if loadControl.scrollToStartWhenFinished { self.scrollToStart() }
                    else { self.scrollToLoadingIndicatorIfNeeded(reveal: false, force: false) }
                }
                
                /// `Curtain is closing` they're throwing roses at my feet
                loadingView.isHidden = true
                if loadingView.responds(to: #selector(UIActivityIndicatorView.stopAnimating)) {
                    loadingView.perform(#selector(UIActivityIndicatorView.stopAnimating))
                }
                
                /// `Reset` scroll state
                if !self.isDragging { Async.immediately { loadControl.isLoading = false } }
                else { Async.delay(.milliseconds(500)) { loadControl.isLoading = false } }
                
                /// Call `completion handler`
                completion?(self)
            })
        }
    }

    /// Called whenever `self.contentOffset` changes.
    fileprivate func loadingScrollViewDidScroll(with contentOffset: CGPoint) {
        /// Is `user initiated?`
        if !self.isDragging && !UIAccessibility.isVoiceOverRunning { return }

        if let loadControl = self.loadControl {
            let contentSize: CGFloat = self.clampToFitVisibleBounds(with: self.contentSize)
            
            switch loadControl.direction {
                
            case .vertical: /// The `lower bound` when loading should kick in
                var actionOffset = CGPoint(x: 0, y: contentSize - self.bounds.size.height + self.originalLoadingEndInset())
                actionOffset.y -= loadControl.triggerOffset
                
                if contentOffset.y > actionOffset.y &&
                    self.panGestureRecognizer.velocity(in: self).y <= 0 { self.beginLoadingIfNeeded(false) }
                
            case .horizontal: /// The `lower bound` when loading should kick in
                var actionOffset = CGPoint(x: contentSize - self.bounds.size.width + self.originalLoadingEndInset(), y: 0)
                actionOffset.x -= loadControl.triggerOffset
                
                if contentOffset.x > actionOffset.x &&
                    self.panGestureRecognizer.velocity(in: self).x <= 0 { self.beginLoadingIfNeeded(false) }
            }
        }
    }

    /// Scrolls view `to start`
    fileprivate func scrollToStart() {
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

    /// Scrolls to activity indicator if it is `partially visible`
    /// - Parameters:
    ///  - reveal scroll to reveal or hide activity indicator
    ///  - force forces scroll to bottom
    internal func scrollToLoadingIndicatorIfNeeded(reveal: Bool, force: Bool) {
        /// Do not interfere with user
        if self.isDragging { return }

        if let loadControl = self.loadControl {
            /// Filter out calls from pan gesture
            if !loadControl.isLoading { return }
            
            /// Force table view to update content size
            if let tableView = self as? UITableView { tableView.forceUpdateContentSize() }
            
            let contentSize: CGFloat = self.clampToFitVisibleBounds(with: self.contentSize)
            let indicatorRowSize: CGFloat = self.loadingIndicatorRowSize()
            
            switch loadControl.direction {
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
