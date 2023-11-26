//
//  Operators.swift
//  
//
//  Created by Krisztian Kemenes on 26.11.2023.
//

import Foundation

/// Move the input point by a size. Adds width to x and height to y
func +(point: CGPoint, size: CGSize) -> CGPoint {
    CGPoint(x: point.x + size.width, y: point.y + size.height)
}

/// Multiply both components of the input size by a multiplier value
func *(size: CGSize, multiplier: CGFloat) -> CGSize {
    CGSize(width: size.width * multiplier, height: size.height * multiplier)
}

func *(size: CGSize, multiplier: Int) -> CGSize {
    return size * CGFloat(multiplier)
}
