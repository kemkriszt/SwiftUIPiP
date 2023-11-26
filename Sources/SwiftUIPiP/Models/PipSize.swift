//
//  PipSize.swift
//
//
//  Created by Krisztian Kemenes on 26.11.2023.
//

import SwiftUI

/// Represents the size of the pip view. The raw value represents the scale compared to the small size
enum PipSize: CGFloat {
    case small = 1
    case medium = 1.5
    case large = 2
}

extension Array where Element == PipSize {
    static var allSizes: Self {
        [.large, .medium, .small]
    }
}
