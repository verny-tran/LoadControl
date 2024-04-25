//
//  Collection.swift
//  LoadControl-Demo
//
//  Created by Trần T. Dũng on 25/4/24.
//

import Foundation

extension Collection {
    /// - Returns: The element at the `specified index` if it is `within bounds`, otherwise ``nil``.
    subscript (safe index: Index) -> Element? {
        return self.indices.contains(index) ? self[index] : nil
    }
}
