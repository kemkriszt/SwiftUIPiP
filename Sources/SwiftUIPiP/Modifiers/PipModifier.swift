//
//  PipModifier.swift
//
//
//  Created by Krisztian Kemenes on 26.11.2023.
//

import SwiftUI

public struct PipModifier<ContentView: View>: ViewModifier {
    @State private var rotation: CGFloat = 0
    @State private var scale: CGFloat = 1
    @State private var offset: CGSize = .zero
    
    @State private var position: PipPosition = .topLeading
    @State private var currentSize: PipSize = .small
    
    @ViewBuilder let contentView: () -> ContentView
    
    let baseSize: CGSize
    let enabledPosition: Set<PipPosition>
    let enabledSizes: Set<PipSize>
    
    private var size: CGSize {
        return baseSize * self.currentSize.rawValue
    }
    
    private var scaleAnchor: UnitPoint {
        switch self.position {
        case .bottomLeading: return .bottomLeading
        case .bottomTrailing: return .bottomTrailing
        case .topLeading: return .topLeading
        case .topTrailing: return .topTrailing
        }
    }
    
    init(baseSize: CGSize = CGSize(width: 150, height: 100),
         enabledPosition: [PipPosition],
         enabledSizes: [PipSize],
         contentView: @escaping () -> ContentView) {
        
        self.baseSize = baseSize
        self.contentView = contentView
        self.enabledPosition = Set(enabledPosition)
        self.enabledSizes = Set(enabledSizes)
    }
    
    public func body(content: Content) -> some View {
        return GeometryReader { proxy in
            content.overlay(alignment: self.position.alignemnt) {
                contentView()
                    .frame(width: size.width, height: size.height)
                    .padding()
                    .contentShape(Rectangle())
                    .scaleEffect(scale, anchor: scaleAnchor)
                    .rotationEffect(.degrees(self.rotation), anchor: .bottom)
                    .offset(offset)
                    .gesture(
                        self.magnifyGesture()
                            .simultaneously(with: dragGesture(proxy: proxy))
                            .simultaneously(with: rotateGesture())
                    )
            }
        }
    }
    
    // MARK: - Gestures
    
    private func magnifyGesture() -> some Gesture {
        MagnifyGesture()
            .onChanged { value in
                withAnimation(.interactiveSpring) {
                    self.scale = value.magnification.max(3)
                }
            }
            .onEnded { _ in
                withAnimation(.spring(.bouncy())) {
                    self.currentSize = self.newSize()
                    self.scale = 1
                }
            }
    }
    
    private func rotateGesture() -> some Gesture {
        RotateGesture()
                .onChanged { gesture in
                    withAnimation(.interactiveSpring) {
                        self.rotation = (gesture.rotation.degrees / 2).between(-10...10)
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(.bouncy())) {
                        self.rotation = 0
                    }
                }
    }
    
    private func dragGesture(proxy: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { gesture in
                withAnimation(.interactiveSpring) {
                    self.offset = gesture.translation
                }
            }
            .onEnded { gesture in
                var finalPosition = self.newPosition(with: gesture.translation,
                                                     and: proxy)
                if finalPosition == self.position {
                    finalPosition = self.newPosition(with: gesture.velocity,
                                                     and: proxy)
                }
                withAnimation(.spring(.bouncy())) {
                    if self.enabledPosition.contains(finalPosition) {
                        self.position = finalPosition
                    }
                    self.offset = .zero
                }
            }
    }
    
    // MARK: - Helpers
    
    private func newSize() -> PipSize {
        let newSize = self.currentSize.rawValue * self.scale
        return PipSize.closest(to: newSize)
    }
    
    private func newPosition(with translation: CGSize, and proxy: GeometryProxy) -> PipPosition {
        // Compare the center of the view to all 4 corners of the parent and find which one is
        // closer to the current position where the user holds the view
        let frame = proxy.frame(in: .local)
        // Calculate the current location
        let originalLocation = self.location(for: self.position, in: frame)
        let newLocation = originalLocation + translation

        // Calculate the center point relative to self
        let midX = size.width / 2
        let midY = size.width / 2
        
        // Calculate deltas. We offset the parent frames dimensions with our current size so we are
        // not comparing to the parent's border
        let deltaLeading = abs(midX - newLocation.x)
        let deltaTrailing = abs(frame.width - midX - newLocation.x)
        let deltaTop = abs(midY - newLocation.y)
        let deltaBottom = abs(frame.height - midY - newLocation.y)
        
        // Find the smaller delta
        let minDeltaY = min(deltaTop, deltaBottom)
        let minDeltaX = min(deltaLeading, deltaTrailing)
        
        // Determine position
        let isTrailing = minDeltaX == deltaTrailing
        let isTop = minDeltaY == deltaTop
        
        switch (isTrailing, isTop) {
        case (true, true):
            return .topTrailing
        case (true, false):
            return .bottomTrailing
        case (false, true):
            return .topLeading
        case (false, false):
            return .bottomLeading
        }
    }
    
    /// Return the center point in the given frame corresponding to the current position
    /// - Note: The current position is determined by the current PipPosition and ignores the current offset
    private func location(for currentPosition: PipPosition, in frame: CGRect) -> CGPoint {
        // Center point relative to self
        let midX = size.width / 2
        let midY = size.height / 2
        
        switch currentPosition {
        case .topLeading: return .init(x: midX, y: midY)
        case .topTrailing: return .init(x: frame.width - midX, y: midY)
        case .bottomLeading: return .init(x: midX, y: frame.height - midY)
        case .bottomTrailing: return .init(x: frame.width - midX, y: frame.height - midY)
        }
    }
}

public extension View {
    /// Presents the ``content`` as a PiP view over the view that it is applied to
    func pip(positions: [PipPosition] = .allPositions,
             sizes: [PipSize] = .allSizes,
             content: @escaping () -> some View) -> some View {
        self.modifier(PipModifier(enabledPosition: positions,
                                  enabledSizes: sizes,
                                  contentView: content))
    }
}


#Preview {
    VStack {
        Text("Hello, World!")
    }
    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    .background(Color.red)
    .pip {
        Color.yellow
            .clipShape(RoundedRectangle(cornerRadius: 15.0))
    }
}
