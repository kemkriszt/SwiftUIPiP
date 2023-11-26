//
//  Numeric+Limits.swift
//  
//
//  Created by Krisztian Kemenes on 26.11.2023.
//

import Foundation

extension Numeric where Self: Comparable {
    
    /// Limit the value by an upper limit.
    /// - Returns: This value or the limit if the value is greater than it
    func max(_ limit: Self) -> Self {
        Swift.min(self, limit)
    }

    /// Limit the value by a lower limit
    /// - Returns: This value or the limit if the value is smaller than it
    func min(_ limit: Self) -> Self {
        Swift.max(self, limit)
    }
    
    /// Returns the value limited between the bounds of the given range
    /// - Returns: If the value is between bounds, it will be returned, otherwise either the upper or the lower limit will be returned
    /// depending on on which end the value overflows the range
    func between(_ range: ClosedRange<Self>) -> Self {
        self.max(range.upperBound).min(range.lowerBound)
    }
}
