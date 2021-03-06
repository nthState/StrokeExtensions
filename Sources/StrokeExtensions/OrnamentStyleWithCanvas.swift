//
//  OrnamentStyleWithCanvas.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/main/LICENSE for license information.
//

import SwiftUI
import CoreGraphics
import simd

/**
 Prefer using OrnamentStyle over OrnamentStyleWithCanvas.
 
 OrnamentStyleWithCanvas is a test to see how one could get the stroke extensions working with `Canvas`
 */
public struct OrnamentStyleWithCanvas<S, NewContent>: ViewModifier, ShapeStyle where S: Shape, NewContent: View {
  
  private let shape: S
  private let path: Path
  private let innerContent: (Int, LayoutData) -> NewContent
  private let itemCount: Int
  private let from: CGFloat
  private let spacing: CGFloat
  private let distribution: Distribution
  private let direction: Direction
  private let accuracy: UInt
  private let size: CGSize
  private let opaque: Bool
  private let colorMode: ColorRenderingMode

  public init(shape: S,
              @ViewBuilder innerContent: @escaping (Int, LayoutData) -> NewContent,
              itemCount: Int = 1,
              from: CGFloat = 0,
              spacing: CGFloat = 0,
              distribution: Distribution = .evenly,
              direction: Direction = .forward,
              size: CGSize = CGSize(width: 40, height: 40),
              opaque: Bool = false,
              colorMode: ColorRenderingMode = .linear,
              accuracy: UInt = 100) {
    
    self.shape = shape
    self.path = shape.path(in: CGRect.unit)
    self.innerContent = innerContent
    self.itemCount = itemCount
    self.from = from
    self.spacing = spacing
    self.distribution = distribution
    self.direction = direction
    self.accuracy = accuracy
    self.size = size
    self.opaque = opaque
    self.colorMode = colorMode
  }
  
  public func body(content: Content) -> some View {
    
    let traverser = PathTraversal(shape: self.shape,
                                   itemCount: self.itemCount,
                                   from: self.from,
                                   spacing: self.spacing,
                                   distribution: self.distribution,
                                   direction: self.direction,
                                   accuracy: self.accuracy)
    
    return Canvas(opaque: opaque, colorMode: colorMode, rendersAsynchronously: true) { context, size in
      
      var resolved: [GraphicsContext.ResolvedSymbol] = []

      for symbolIndex in 0..<self.itemCount {
        guard let symbol = context.resolveSymbol(id: "ornament_\(symbolIndex)") else {
          fatalError("No content specified for: \(symbolIndex)")
        }
        resolved.append(symbol)
      }

      traverser.traverse(callback: { element, data in
        switch element {
        case .move(to: _):
          break
        case .line(to: _):
          drawSymbol(resolvedSymbol: resolved[data.index], on: context, at: data.newPoint, angle: data.angle, leftNormal: data.leftNormal)
        case .curve(to: _, control1: _, control2: _):
          drawSymbol(resolvedSymbol: resolved[data.index], on: context, at: data.newPoint, angle: data.angle, leftNormal: data.leftNormal)
        case .quadCurve(to: _, control: _):
          drawSymbol(resolvedSymbol: resolved[data.index], on: context, at: data.newPoint, angle: data.angle, leftNormal: data.leftNormal)
        case .closeSubpath:
          drawSymbol(resolvedSymbol: resolved[data.index], on: context, at: data.newPoint, angle: data.angle, leftNormal: data.leftNormal)
        }
      })
      
      
    } symbols: {

      ForEach(((0..<Int(self.itemCount))), id: \.self) { index in
        innerContent(index, LayoutData(position: .zero, angle: .zero, leftNormal: .zero))
          .tag("ornament_\(index)")
          .frame(width: self.size.width, height: self.size.height)
      }

    }
    
  }
  
  private func drawSymbol(resolvedSymbol: GraphicsContext.ResolvedSymbol?, on context: GraphicsContext, at point: CGPoint, angle: Angle, leftNormal: CGPoint) {
    
    guard let symbol = resolvedSymbol else {
      return
    }
    
    context.drawLayer { layer in
      layer.translateBy(x: point.x * self.size.width, y: point.y * self.size.height)
      layer.rotate(by: angle)
      layer.draw(symbol, at: .zero, anchor: .center)
    }
  }
  
}
