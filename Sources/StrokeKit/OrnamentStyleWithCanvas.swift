//
//  File.swift
//  
//
//  Created by Chris Davis on 30/12/2021.
//

import SwiftUI
import CoreGraphics
import simd

public struct OrnamentStyleWithCanvas<S, NewContent>: ViewModifier, ShapeStyle where S: Shape, NewContent: View {
  
  private let shape: S
  private let path: Path
  private let innerContent: (UInt, LayoutData) -> NewContent
  private let itemCount: UInt
  //private var traverser: PathTraversal<S>
  private let from: CGFloat
  private let spacing: CGFloat
  private let distribution: Distribution
  private let spawn: Spawn
  private let accuracy: UInt
  private let size: CGSize

  public init(shape: S,
              @ShapeContentBuilder innerContent: @escaping (UInt, LayoutData) -> NewContent,
              itemCount: UInt = 1,
              from: CGFloat = 0,
              spacing: CGFloat = 0,
              distribution: Distribution = .evenly,
              spawn: Spawn = .forward,
              size: CGSize = CGSize(width: 40, height: 40),
              accuracy: UInt = 100) {
    
    self.shape = shape
    self.path = shape.path(in: CGRect.unit)
    self.innerContent = innerContent
    self.itemCount = itemCount
    self.from = from
    self.spacing = spacing
    self.distribution = distribution
    self.spawn = spawn
    self.accuracy = accuracy
    self.size = size
  }
  
  public func body(content: Content) -> some View {
    
    let traverser = PathTraversal(shape: self.shape,
                                   //innerContent: innerContent,
                                   itemCount: self.itemCount,
                                   from: self.from,
                                   spacing: self.spacing,
                                   distribution: self.distribution,
                                   spawn: self.spawn,
                                   accuracy: self.accuracy)
    
    return Canvas(opaque: false, colorMode: .linear, rendersAsynchronously: true) { context, size in
      
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
          drawSymbol(resolvedSymbol: resolved[data.index], on: context, at: data.newPoint, angle: data.angle, leftNormal: data.leftNormal)
        case .curve(to: let point, control1: let control1, control2: let control2):
          drawSymbol(resolvedSymbol: resolved[data.index], on: context, at: data.newPoint, angle: data.angle, leftNormal: data.leftNormal)
        case .quadCurve(to: let point, control: let control):
          break
        case .closeSubpath:
          drawSymbol(resolvedSymbol: resolved[data.index], on: context, at: data.newPoint, angle: data.angle, leftNormal: data.leftNormal)
        }
      })
      
      
    } symbols: {
      
      #warning("fix this")
//      ForEach<Range<Int>, Int, ModifiedContent<ModifiedContent<_ConditionalContent<ModifiedContent<ModifiedContent<ModifiedContent<ModifiedContent<ModifiedContent<_ShapeView<Rectangle, Color>, _FrameLayout>, _OverlayModifier<_ShapeView<_StrokedShape<_Inset>, Color>>>, _RotationEffect>, _AnimationModifier<Bool>>, _AppearanceActionModifier>, ModifiedContent<ModifiedContent<ModifiedContent<ModifiedContent<ModifiedContent<_ShapeView<Rectangle, Color>, _FrameLayout>, _OverlayModifier<_ShapeView<_StrokedShape<_Inset>, Color>>>, _RotationEffect>, _AnimationModifier<Bool>>, _AppearanceActionModifier>>, _TraitWritingModifier<TagValueTraitKey<String>>>, _FrameLayout>> count (4) != its initial count (3). `ForEach(_:content:)` should only be used for *constant* data. Instead conform data to `Identifiable` or use `ForEach(_:id:content:)` and provide an explicit `id`!
      
      ForEach(((0..<Int(self.itemCount))), id: \.self) { index in
        innerContent(UInt(index), LayoutData(position: .zero, angle: .zero, leftNormal: .zero))
          
          //.view
          .tag("ornament_\(index)")
          .frame(width: self.size.width, height: self.size.height)
      }
      
//      ForEach((0..<Int(self.itemCount))) { index in
//        innerContent(UInt(index), LayoutData(position: .zero, angle: .zero, leftNormal: .zero))
//          //.view
//          .tag("ornament_\(index)")
//          .frame(height: 100)
//      }

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
