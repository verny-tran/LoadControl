//
//  UIView.swift
//  LoadControl
//
//  Created by Trần T. Dũng on 22/4/24.
//

import UIKit

extension UIView {
    func constraint(to view: UIView, anchor: NSLayoutConstraint.Attribute,
                    pivot: NSLayoutConstraint.Attribute, inset: CGFloat = 0) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(
            item: self, attribute: anchor, relatedBy: .equal,
            toItem: view, attribute: pivot, multiplier: 1, constant: inset
        )
        
        constraint.isActive = true
    }
}
