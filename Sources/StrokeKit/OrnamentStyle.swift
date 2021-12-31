//
//  File.swift
//  
//
//  Created by Chris Davis on 30/12/2021.
//

import SwiftUI
import CoreGraphics
import simd

 struct ViewItem: Identifiable {
  let id: UUID
  let view: AnyView
  
  public init(id: UUID, view: AnyView) {
    self.id = id
    self.view = view
  }
}

public struct OrnamentStyle<S, NewContent>: ViewModifier, ShapeStyle where S: Shape, NewContent: View {
  
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
  
  public func body(content: Content) -> some View {
    
    let items = buildAubViews(content: content)
    
    ZStack {
      ForEach(items, id: \.id) { ornamentView in
        ornamentView
          .view
      }
    }
    
  }
  
  private func drawView(at point: CGPoint, angle: Angle) -> some View {
    
    innerContent
      
      .id(UUID())
      .rotationEffect(angle)
      .offset(x: point.x/2, y: point.y/2)
      .position(x: point.x/2, y: point.y/2)
      
    
  }
  
  func buildAubViews(content: Content) -> [ViewItem] {
    
    var views: [ViewItem] = []
    let innerContentWidth: CGFloat = 100
    let size: CGSize = CGSize(width: 100, height: 100)
    var startPoint: CGPoint = .zero
    var lastPoint: CGPoint = .zero
    path.forEach { element in
      switch element {
      case .move(to: let point):

        startPoint = point
        lastPoint = point
      case .line(to: let point):
        
        let length = lastPoint.distance(to: point)
        let repeatCount = self.itemCount ?? UInt((length * 100) / innerContentWidth)
        
        let itemCount: CGFloat = CGFloat(repeatCount)
        let by: CGFloat = 1 / itemCount
        
        var tempLast = lastPoint
        for item in stride(from: 0, through: 1, by: by) {
          
          
          let newCGPoint = mix(SIMD2<Float>(lastPoint), SIMD2<Float>(point), t: Float(item))
          
          let angleInDegrees = tempLast.angle(between: newCGPoint.cgPoint)
          
          let newPoint = newCGPoint.cgPoint * size
          
          let view = AnyView(drawView(at: newPoint, angle: Angle(degrees: angleInDegrees)))
          views.append(ViewItem(id: UUID(), view: view))
          
          tempLast = newCGPoint.cgPoint
        }
        
        
        lastPoint = point
      case .curve(to: let point, control1: let control1, control2: let control2):
        
        let length = bezier_length(start: lastPoint, p1: control1, p2: control2, finish: point, accuracy: self.accuracy)
        let lengths = bezier_arcLengths(start: lastPoint, p1: control1, p2: control2, finish: point, accuracy: self.accuracy)
        
        let repeatCount = self.itemCount ?? UInt((length * 100) / innerContentWidth)
        
        let itemCount: CGFloat = CGFloat(repeatCount)
        let by: CGFloat = 1 / itemCount
        
        var tempLast = lastPoint
        for item in stride(from: 0, through: 1, by: by) {
          
          let e = bezier_evenlyDistributed(u: item, arcLengths: lengths)
          
          let x = _bezier_point_x(t: e, a: lastPoint, b: control1, c: control2, d: point)
          let y = _bezier_point_y(t: e, a: lastPoint, b: control1, c: control2, d: point)
          
          
          let angleInDegrees = tempLast.angle(between: CGPoint(x: x, y: y))
          //let angleInDegrees = CGPoint(x: x, y: y).angle(between: tempLast)
          
          let newPoint = CGPoint(x: x, y: y) * size
          
          let view = AnyView(drawView(at: newPoint, angle: Angle(degrees: angleInDegrees)))
          views.append(ViewItem(id: UUID(), view: view))
          
          tempLast = CGPoint(x: x, y: y)
          
        }
        
        lastPoint = point
      case .quadCurve(to: let point, control: let control):
        
        lastPoint = point
      case .closeSubpath:
        let length = lastPoint.distance(to: startPoint)
        let repeatCount = self.itemCount ?? UInt((length * 100) / innerContentWidth)
        
        let itemCount: CGFloat = CGFloat(repeatCount)
        let by: CGFloat = 1 / itemCount
        
        var tempLast = lastPoint
        for item in stride(from: 0, through: 1, by: by) {
          
          
          let newCGPoint = mix(SIMD2<Float>(lastPoint), SIMD2<Float>(startPoint), t: Float(item))
          
          let angleInDegrees = tempLast.angle(between: newCGPoint.cgPoint)
          
          let newPoint = newCGPoint.cgPoint * size
          
          let view = AnyView(drawView(at: newPoint, angle: Angle(degrees: angleInDegrees)))
          views.append(ViewItem(id: UUID(), view: view))
          
          tempLast = newCGPoint.cgPoint
        }
        
      }
    }
    
    return views
  }
  
}
