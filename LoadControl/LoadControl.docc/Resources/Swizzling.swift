//
//  Swizzling.swift
//  LoadControl
//
//  Created by Trần T. Dũng on 22/4/24.
//

import UIKit

// !!!: IMPORTANT 📛 VERY DANGEROUS
private enum Swizzling {
    case `class`
    case instance
    
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
    /// ONLY **SWIZZLE** the `UIScrollView's` <loading> methods
    /// of <loadingContentOffset(_:)> & <loadingContentSize(_:)> for once in the app life cycle!!!
    
    static let swizzle: Void = {
        Swizzling.swizzle(UIScrollView.self, case: .instance,
                          original: #selector(setter: UIScrollView.contentOffset),
                          swizzled: #selector(UIScrollView.loadingContentOffset(_:)))
        
        Swizzling.swizzle(UIScrollView.self, case: .instance,
                          original: #selector(setter: UIScrollView.contentSize),
                          swizzled: #selector(UIScrollView.loadingContentSize(_:)))
    }()
}
