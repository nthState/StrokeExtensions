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
  
  private let path: Path
  private let innerContent: NewContent
  private let direction: Direction
  private let itemCount: UInt?
  private let spacing: [CGFloat]
  private let accuracy: UInt
  
  private let _totalLength: CGFloat
  private let _totalSections: UInt
  
  public init(shape: S,
              @ViewBuilder innerContent: @escaping () -> NewContent,
              direction: Direction = .rightToLeft,
              itemCount: UInt? = nil,
              spacing: [CGFloat] = [],
              accuracy: UInt = 100) {
    
    self.path = shape.path(in: CGRect.unit)
    self.innerContent = innerContent()
    self.direction = direction
    self.itemCount = itemCount
    self.spacing = spacing
    self.accuracy = accuracy
    
    (self._totalLength, self._totalSections) = self.path.totalLength()
  }
  
  private func drawSymbol(resolvedSymbol: GraphicsContext.ResolvedSymbol, on context: GraphicsContext, at point: CGPoint, angle: Angle) {
    context.drawLayer { layer in
      layer.translateBy(x: point.x, y: point.y)
      layer.rotate(by: angle)
      layer.draw(resolvedSymbol, at: .zero, anchor: .center)
    }
  }
  
  public func body(content: Content) -> some View {
    
    Canvas(opaque: false, colorMode: .linear, rendersAsynchronously: false) { context, size in
      
      context.draw(Text("test"), at: CGPoint(x: 20, y: 20))
      
      guard let r0 = context.resolveSymbol(id: "item0") else {
        print("No content specified")
        return
      }
      
      //var distanceTravelled: CGFloat = 0
      var startPoint: CGPoint = .zero
      var lastPoint: CGPoint = .zero
      path.forEach { element in
        switch element {
        case .move(to: let point):

          startPoint = point
          lastPoint = point
        case .line(to: let point):
          
          let length = lastPoint.distance(to: point)
          let repeatCount = self.itemCount ?? UInt((length * 100) / r0.size.width)
          
          let itemCount: CGFloat = CGFloat(repeatCount)
          let by: CGFloat = 1 / itemCount
          
          var tempLast = lastPoint
          for item in stride(from: 0, through: 1, by: by) {
            
            
            let newCGPoint = mix(SIMD2<Float>(lastPoint), SIMD2<Float>(point), t: Float(item))
            
            let angleInDegrees = tempLast.angle(between: newCGPoint.cgPoint)
            
            let newPoint = newCGPoint.cgPoint * size
            
            drawSymbol(resolvedSymbol: r0, on: context, at: newPoint, angle: Angle(degrees: angleInDegrees))
            
            tempLast = newCGPoint.cgPoint
          }
          
          
          lastPoint = point
        case .curve(to: let point, control1: let control1, control2: let control2):
          
          let length = bezier_length(start: lastPoint, p1: control1, p2: control2, finish: point, accuracy: self.accuracy)
          let lengths = bezier_arcLengths(start: lastPoint, p1: control1, p2: control2, finish: point, accuracy: self.accuracy)
          
          let repeatCount = self.itemCount ?? UInt((length * 100) / r0.size.width)
          
          let itemCount: CGFloat = CGFloat(repeatCount)
          let by: CGFloat = 1 / itemCount
          
          var tempLast = lastPoint
          for item in stride(from: 0, through: 1, by: by) {
            
            let e = bezier_evenlyDistributed(u: item, arcLengths: lengths)
            
            let x = _bezier_point_x(t: e, a: lastPoint, b: control1, c: control2, d: point)
            let y = _bezier_point_y(t: e, a: lastPoint, b: control1, c: control2, d: point)
            
            
            let angleInDegrees = tempLast.angle(between: CGPoint(x: x, y: y))
            
            let newPoint = CGPoint(x: x, y: y) * size
            
            drawSymbol(resolvedSymbol: r0, on: context, at: newPoint, angle: Angle(degrees: angleInDegrees))
            
            tempLast = CGPoint(x: x, y: y)
            
          }
          
          lastPoint = point
        case .quadCurve(to: let point, control: let control):
          
          lastPoint = point
        case .closeSubpath:
          let length = lastPoint.distance(to: startPoint)
          let repeatCount = self.itemCount ?? UInt((length * 100) / r0.size.width)
          
          let itemCount: CGFloat = CGFloat(repeatCount)
          let by: CGFloat = 1 / itemCount
          
          var tempLast = lastPoint
          for item in stride(from: 0, through: 1, by: by) {
            
            
            let newCGPoint = mix(SIMD2<Float>(lastPoint), SIMD2<Float>(startPoint), t: Float(item))
            
            let angleInDegrees = tempLast.angle(between: newCGPoint.cgPoint)
            
            let newPoint = newCGPoint.cgPoint * size
            
            drawSymbol(resolvedSymbol: r0, on: context, at: newPoint, angle: Angle(degrees: angleInDegrees))
            
            tempLast = newCGPoint.cgPoint
          }
          
        }
      }
      
      
    } symbols: {
      
      innerContent
        .tag("item0")
      
    }
    
  }
}
