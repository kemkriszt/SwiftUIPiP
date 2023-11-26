//
//  PipModifier.swift
//
//
//  Created by Krisztian Kemenes on 26.11.2023.
//

import SwiftUI

public struct PipModifier<ContentView: View>: ViewModifier {
    private let baseSize = CGSize(width: 150, height: 100)
    
    @State private var rotation: CGFloat = 0
    @State private var scale: CGFloat = 1
    @State private var offset: CGSize = .zero
    
    @State private var position: PipPosition = .topLeading
    @State private var currentSize: PipSize = .small
    
    @ViewBuilder let contentView: () -> ContentView
    
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
    
    init(enabledPosition: [PipPosition],
         enabledSizes: [PipSize],
         contentView: @escaping () -> ContentView) {
        
        self.contentView = contentView
        self.enabledPosition = Set(enabledPosition)
        self.enabledSizes = Set(enabledSizes)
    }
    
    /// This could probably be written more inteligently but its good enough for now
    private func getNewSize() -> PipSize {
        let newSize = self.currentSize.rawValue * self.scale
        
        if newSize < PipSize.small.rawValue {
            return .small
        } else if newSize >= PipSize.small.rawValue && newSize < PipSize.medium.rawValue {
            let deltaSmall = newSize - PipSize.small.rawValue
            let deltaMedium = PipSize.medium.rawValue - newSize
            
            if deltaSmall > deltaMedium {
                return .medium
            } else {
                return .small
            }
        } else if newSize >= PipSize.medium.rawValue  && newSize < PipSize.large.rawValue {
            let deltaMedium = newSize - PipSize.medium.rawValue
            let deltaLarge = PipSize.large.rawValue - newSize
            
            if deltaMedium > deltaLarge {
                return .large
            } else {
                return .medium
            }
        } else {
            return .large
        }
    }
    
    private func newPosition(with translation: CGSize, and proxy: GeometryProxy) -> PipPosition {
        // TODO: Use distance of each corner to their coresponding corner of the parent otherwise the large size may not provide a good UX
        let frame = proxy.frame(in: .local)
        let originalLocation = self.location(for: self.position, in: frame)
        let newLocation = originalLocation + translation
        
        let isTrailing = newLocation.x > frame.width / 2
        let isTop = newLocation.y < frame.height / 2
        
        
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
                        MagnifyGesture()
                            .onChanged { value in
                                withAnimation(.interactiveSpring) {
                                    self.scale = value.magnification.max(3)
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.spring(.bouncy())) {
                                    self.currentSize = self.getNewSize()
                                    self.scale = 1
                                }
                            }.simultaneously(with: DragGesture()
                                .onChanged { gesture in
                                    withAnimation(.interactiveSpring) {
                                        self.offset = gesture.translation
                                    }
                                }
                                .onEnded { gesture in
                                    // TODO: Velocity
                                    
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
                                }).simultaneously(with: RotateGesture()
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
                                )
                    )
            }
        }
    }
    
    private func location(for currentPosition: PipPosition, in frame: CGRect) -> CGPoint {
        switch currentPosition {
        case .topLeading: .init(x: 0, y: 0)
        case .topTrailing: .init(x: frame.width, y: 0)
        case .bottomLeading: .init(x: 0, y: frame.height)
        default: .init(x: frame.width, y: frame.height)
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