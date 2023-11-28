//
//  PipSize.swift
//
//
//  Created by Krisztian Kemenes on 26.11.2023.
//

import SwiftUI

/// Represents the size of the pip view. The raw value represents the scale compared to the small size
public enum PipSize: CGFloat {
    case small = 1
    case medium = 1.5
    case large = 2
    
    static func closest(to value: CGFloat) -> PipSize {
        if value < PipSize.small.rawValue {
            return .small
        } else if PipSize.small...PipSize.medium ~= value {
            return closes(to: value, between: .small, and: .medium)
        } else if PipSize.medium...PipSize.large ~= value {
            return closes(to: value, between: .medium, and: .large)
        } else {
            return .large
        }
    }
    
    private static func closes(to value: CGFloat, between lower: PipSize, and upper: PipSize) -> PipSize {
        let newRawValue = value.closest(of: lower...upper)
        return PipSize(rawValue: newRawValue) ?? .small
    }
}

func ...(lower: PipSize, upper: PipSize) -> ClosedRange<PipSize.RawValue> {
    lower.rawValue...upper.rawValue
}

public extension Array where Element == PipSize {
    static var allSizes: Self {
        [.large, .medium, .small]
    }
}
