//
//  PipPosition.swift
//
//
//  Created by Krisztian Kemenes on 26.11.2023.
//

import SwiftUI

/// Represents the position of the PiP view in the parent
enum PipPosition {
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing
    
    var alignemnt: Alignment {
        switch self {
        case .topLeading: return .topLeading
        case .bottomLeading: return .bottomLeading
        case .bottomTrailing: return .bottomTrailing
        case .topTrailing: return .topTrailing
        }
    }
}

extension Array where Element == PipPosition {
    static var allPositions: Self {
        [.topLeading, .topTrailing, .bottomTrailing, .bottomLeading]
    }
}

