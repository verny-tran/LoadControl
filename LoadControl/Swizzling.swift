//
//  Swizzling.swift
//  LoadControl
//
//  Created by Trần T. Dũng on 22/4/24.
//

import UIKit

/// `METHOD SWIZZLING` cases.
///
/// - Important: 📛 `VERY DANGEROUS`. Do not use this `irresponsibly`.
///   Please remember to always `swizzle a class for once` in the app life cycle!!!
///
/// - Note: Please put `all of the method swizzled classes` in this file for `safety tracking`.
///
/// - Experiment:
///   - [1]. Some `method to be swizzled` is an <instance> method. [E.g]: The method <setter: .contentSize> of <UIScrollView>.
///
///     ```
///     Swizzling.swizzle(UIScrollView.self, case: .instance,
///                       original: #selector(setter: UIScrollView.contentSize),
///                       swizzled: #selector(UIScrollView.loadingContentSize(_:)))
///     ```
///   - [2]. While others is a <class> method. [E.g]: The method <systemFont(ofSize:)> of <UIFont>.
///     ```
///     Swizzling.swizzle(UIFont.self, case: .class,
///                       original: #selector(UIFont.systemFont(ofSize:)),
///                       swizzled: #selector(UIFont.customFont(ofSize:)))
///     ```
///
private enum Swizzling {
    case `class`
    case instance
    
    /// The designated function for `method swizzling`.
    ///
    /// - Parameters:
    ///   - aClass: The target class to be swizzled.
    ///   - swizzling: The `swizzling` case, <class> or <instance>. `Most of the time`, it will be <instance>.
    ///   - original: The original selector action of the class.
    ///   - swizzled: The swizzled selector action of the class.
    ///
    fileprivate static func swizzle(_ aClass: AnyClass, case swizzling: Swizzling, original: Selector, swizzled: Selector) {
        let originalMethod = swizzling == .class ? class_getClassMethod(aClass, original) : class_getInstanceMethod(aClass, original)
        let swizzledMethod = swizzling == .class ? class_getClassMethod(aClass, swizzled) : class_getInstanceMethod(aClass, swizzled)
        
        guard let originalMethod = originalMethod, let swizzledMethod = swizzledMethod else { return }
        guard swizzling == .instance else { method_exchangeImplementations(originalMethod, swizzledMethod); return }
        
        if class_addMethod(aClass, original, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod)) {
            class_replaceMethod(aClass, swizzled, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else { method_exchangeImplementations(originalMethod, swizzledMethod) }
    }
}

extension UIScrollView {
    /// The`swizzled status` of the <UIScrollView>.
    /// Default is ``false``. Set after any <LoadControl> instance `has been created`.
    private(set) static var isSwizzled: Bool = false
    
    /// The designated `swizzle method` of the <UIScrollView>. 
    /// Swizzling <setter: contentOffset> and <setter: contentOffset>
    ///
    /// - Important: ONLY **SWIZZLE** the `UIScrollView's` <loading> methods
    ///   of <loadingContentOffset(_:)> & <loadingContentSize(_:)> `for once` in the app life cycle!
    ///
    static let swizzle: Void = { UIScrollView.isSwizzled = true /// Change `swizzled status` to ``true``.
        
        Swizzling.swizzle(UIScrollView.self, case: .instance,
                          original: #selector(setter: UIScrollView.contentSize),
                          swizzled: #selector(UIScrollView.loadingContentSize(_:)))
        
        Swizzling.swizzle(UIScrollView.self, case: .instance,
                          original: #selector(setter: UIScrollView.contentOffset),
                          swizzled: #selector(UIScrollView.loadingContentOffset(_:)))
    }()
}
