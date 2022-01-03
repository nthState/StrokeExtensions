//
//  File.swift
//  
//
//  Created by Chris Davis on 30/12/2021.
//

import SwiftUI
import CoreGraphics
import simd

public struct OrnamentStyleWithCanvas<S, NewContent>: ViewModifier, ShapeStyle where S: Shape, NewContent: Ornamentable {
  
  private let path: Path
  private let innerContent: (UInt) -> NewContent
  private let itemCount: UInt
  private let traverser: PathTraversal<S, NewContent>

  public init(shape: S,
              @ShapeContentBuilder innerContent: @escaping (UInt) -> NewContent,
              itemCount: UInt? = nil,
              from: CGFloat = 0,
              offsetPerItem: [CGPoint] = [],
              spacing: [CGFloat] = [],
              layout: Layout = .clockwise,
              accuracy: UInt = 100) {
    
    self.path = shape.path(in: CGRect.unit)
    self.innerContent = innerContent
    self.itemCount = itemCount ?? 5

    self.traverser = PathTraversal(shape: shape,
                                   //innerContent: innerContent,
                                   itemCount: itemCount,
                                   from: from,
                                   offsetPerItem: offsetPerItem,
                                   spacing: spacing,
                                   layout: layout,
                                   accuracy: accuracy)
  }
  
  public func body(content: Content) -> some View {
    
    Canvas(opaque: false, colorMode: .linear, rendersAsynchronously: true) { context, size in
      
      var resolved: [GraphicsContext.ResolvedSymbol] = []

      for symbolIndex in 0..<self.itemCount {
        guard let symbol = context.resolveSymbol(id: "ornament_\(symbolIndex)") else {
          fatalError("No content specified for: \(symbolIndex)")
        }
        resolved.append(symbol)
      }

      traverser.traverse(callback: { element, data in
        switch element {
        case .move(to: let point):
          break
        case .line(to: let point):
          drawSymbol(resolvedSymbol: resolved[data.index], on: context, at: data.newPoint, angle: data.angle)
        case .curve(to: let point, control1: let control1, control2: let control2):
          drawSymbol(resolvedSymbol: resolved[data.index], on: context, at: data.newPoint, angle: data.angle)
        case .quadCurve(to: let point, control: let control):
          break
        case .closeSubpath:
          drawSymbol(resolvedSymbol: resolved[data.index], on: context, at: data.newPoint, angle: data.angle)
        }
      })
      
      
    } symbols: {
      
      ForEach((0..<Int(self.itemCount))) { index in
        innerContent(UInt(index))
          .view
          .tag("ornament_\(index)")
          .frame(height: 100)
      }

    }
    
  }
  
  private func drawSymbol(resolvedSymbol: GraphicsContext.ResolvedSymbol?, on context: GraphicsContext, at point: CGPoint, angle: Angle) {
    
    guard let symbol = resolvedSymbol else {
      return
    }
    
    context.drawLayer { layer in
      layer.translateBy(x: point.x, y: point.y)
      layer.rotate(by: angle)
      layer.draw(symbol, at: .zero, anchor: .center)
    }
  }
  
}
