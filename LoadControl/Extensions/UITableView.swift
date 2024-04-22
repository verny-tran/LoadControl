//
//  UITableView.swift
//  LoadControl
//
//  Created by Trần T. Dũng on 22/4/24.
//

import UIKit

extension UITableView {
    func forceUpdateContentSize() {
        let contentSize = CGSize(width: self.frame.width, height: .greatestFiniteMagnitude)
        self.contentSize = self.sizeThatFits(contentSize)
    }
}
