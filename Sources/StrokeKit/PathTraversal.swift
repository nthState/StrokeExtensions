//
//  File.swift
//  
//
//  Created by Chris Davis on 02/01/2022.
//

import Foundation
import CoreGraphics
import SwiftUI
import simd

private enum PathType {
  case spacer(distance: CGFloat)
  case shape
}

public class PathTraversal<S, NewContent> where S: Shape, NewContent: Ornamentable {
  
  private let path: Path
  //private let innerContent: NewContent
  private let itemCount: UInt?
  private let offsetPerItem: [CGPoint]
  private let from: CGFloat
  private let spacing: [CGFloat]
  private let layout: Layout
  private let accuracy: UInt
  
  private let _totalLength: CGFloat
  private let _totalSegments: UInt
  private let _centerPoint: CGFloat
  
  //private var _distance: CGFloat = 0
  private var _startDistance: CGFloat = 0
  
  private var _items: [PathType] = []
  
  public init(shape: S,
              //@ShapeContentBuilder innerContent: @escaping (UInt) -> NewContent,
              itemCount: UInt?,
              from: CGFloat = 0,
              offsetPerItem: [CGPoint] = [],
              spacing: [CGFloat] = [],
              layout: Layout = .clockwise,
              accuracy: UInt = 100) {
    
    precondition(from >= 0 && from <= 1, "From must be a percentage in range 0.0 to 1.0")
    
    self.path = shape.path(in: CGRect.unit)
    //self.innerContent = innerContent(7)
    self.itemCount = itemCount
    self.offsetPerItem = offsetPerItem
    self.spacing = spacing
    self.from = from
    self.layout = layout
    self.accuracy = accuracy
    
    (self._totalLength, self._totalSegments) = self.path.totalLengthAndSegments()
    
    self._centerPoint = self._totalLength / 2
    self._startDistance = self._totalLength * from
    
//    switch layout {
//    case .clockwise:
//      _distance = 0
//    case .anti_clockwise:
//      _distance = self._totalLength
//    case .both:
//      _distance = self._totalLength / 2
//    }
    
    _items.append(.spacer(distance: self._startDistance))
    
    if let itemCount = self.itemCount {
      let ornamentEvery = Int(floor(self._totalLength / CGFloat(itemCount)))

      for i in 0..<ornamentEvery {
        _items.append(.shape)
        if self.spacing.indices.contains(i) {
          _items.append(.spacer(distance: self.spacing[i]))
        }
      }
    }
    
    
  }
  
}

public extension PathTraversal {
  
  typealias event = (Path.Element, Item) -> ()
  
  struct Item {
    let lastPoint: CGPoint
    let newPoint: CGPoint
    let angle: Angle
    let index: Int
  }
  
  func traverse(callback: event) {
    
    let innerContentWidth: CGFloat = 100
    let size: CGSize = CGSize(width: 100, height: 100)
    var startPoint: CGPoint = .zero
    var lastPoint: CGPoint = .zero
    
    var index: Int = 0
    var distanceTravelled: CGFloat = 0
    
    path.forEach { element in
      switch element {
      case .move(to: let point):

        startPoint = point
        lastPoint = point
        distanceTravelled = 0
        
        callback(.move(to: point), Item(lastPoint: lastPoint, newPoint: point, angle: .zero, index: index))
        
        
      case .line(to: let point):
        
        let length = lastPoint.distance(to: point)
        let repeatCount = 10//self.itemCount ?? UInt((length * 100) / innerContentWidth)
        
        let itemCount: CGFloat = CGFloat(repeatCount)
        let by: CGFloat = 1 / itemCount
        
        var tempLast = lastPoint
        for item in stride(from: 0, through: 1, by: by) {
          
          
          distanceTravelled += by
          guard distanceTravelled >= self._startDistance else {
            continue
          }
          
          let newCGPoint = mix(SIMD2<Float>(lastPoint), SIMD2<Float>(point), t: Float(item))
          
          let angleInDegrees = tempLast.angle(between: newCGPoint.cgPoint)
          
          let newPoint = newCGPoint.cgPoint * size
          
          tempLast = newCGPoint.cgPoint
          
          callback(.line(to: point), Item(lastPoint: tempLast, newPoint: newPoint, angle: Angle(degrees: angleInDegrees), index: index))
          index += 1
        }
        
        
        lastPoint = point
      case .curve(to: let point, control1: let control1, control2: let control2):
        
        let length = bezier_length(start: lastPoint, p1: control1, p2: control2, finish: point, accuracy: self.accuracy)
        let lengths = bezier_arcLengths(start: lastPoint, p1: control1, p2: control2, finish: point, accuracy: self.accuracy)
        
        let repeatCount = 10//self.itemCount ?? UInt((length * 100) / innerContentWidth)
        
        let itemCount: CGFloat = CGFloat(repeatCount)
        let by: CGFloat = 1 / itemCount
        
        var tempLast = lastPoint
        for item in stride(from: 0, through: 1, by: by) {
          
          let e = bezier_evenlyDistributed(u: item, arcLengths: lengths)
          
          distanceTravelled += by
          guard distanceTravelled >= self._startDistance else {
            continue
          }
          
          let x = _bezier_point_x(t: e, a: lastPoint, b: control1, c: control2, d: point)
          let y = _bezier_point_y(t: e, a: lastPoint, b: control1, c: control2, d: point)
          
          let angleInDegrees = tempLast.angle(between: CGPoint(x: x, y: y))
          //let angleInDegrees = CGPoint(x: x, y: y).angle(between: tempLast)
          
          let newPoint = CGPoint(x: x, y: y) * size
          
          tempLast = CGPoint(x: x, y: y)
          
          callback(.curve(to: point, control1: control1, control2: control2), Item(lastPoint: tempLast, newPoint: newPoint, angle: Angle(degrees: angleInDegrees), index: index))
          index += 1
        }
        
        lastPoint = point
      case .quadCurve(to: let point, control: let control):
        
        lastPoint = point
        index += 1
      case .closeSubpath:
        let length = lastPoint.distance(to: startPoint)
        let repeatCount = 10//self.itemCount ?? UInt((length * 100) / innerContentWidth)
        
        let itemCount: CGFloat = CGFloat(repeatCount)
        let by: CGFloat = 1 / itemCount
        
        var tempLast = lastPoint
        for item in stride(from: 0, through: 1, by: by) {
          
          distanceTravelled += by
          guard distanceTravelled >= self._startDistance else {
            continue
          }
          
          let newCGPoint = mix(SIMD2<Float>(lastPoint), SIMD2<Float>(startPoint), t: Float(item))
          
          let angleInDegrees = tempLast.angle(between: newCGPoint.cgPoint)
          
          let newPoint = newCGPoint.cgPoint * size
          
          tempLast = newCGPoint.cgPoint
          
          callback(.closeSubpath, Item(lastPoint: tempLast, newPoint: newPoint, angle: Angle(degrees: angleInDegrees), index: index))
          
          index += 1
        }
        
      }
      
      
    }
    
  }
  
}
