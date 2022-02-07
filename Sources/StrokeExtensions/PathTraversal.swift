//
//  PathTraversal.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/master/LICENSE for license information.
//

import Foundation
import CoreGraphics
import SwiftUI
import simd

internal class PathTraversal<S> where S: Shape {
  
  private let path: Path
  
  private let itemCount: Int
  private let from: CGFloat
  private let spacing: CGFloat
  private let distribution: Distribution
  private let direction: Direction
  private let accuracy: UInt
  
  /// We're doing some dividing later on, add a small amount so we don't get division by zero errors
  private let divisionByZeroMin: CGFloat = 0.0001
  
  private let _totalLength: CGFloat
  private let _totalSegments: UInt
  
  private var _startDistance: CGFloat = 0
  
  private var _segments: [Segment] = []
  
  public init(shape: S,
              itemCount: Int = 1,
              from: CGFloat = 0,
              spacing: CGFloat = 0,
              distribution: Distribution = .evenly,
              direction: Direction = .forward,
              accuracy: UInt = 100) {
    
    precondition(itemCount >= 0, "`itemCount` must be positive")
    precondition(from >= 0 && from <= 1, "`from` must be a percentage in range 0.0 to 1.0")
    
    self.path = shape.path(in: CGRect.unit)
    
    self.spacing = spacing
    self.from = from
    self.distribution = distribution
    self.direction = direction
    self.accuracy = accuracy
    self.itemCount = itemCount
    
    (self._totalLength, self._totalSegments) = self.path.totalLengthAndSegments()
    
    
    // Create an array of segments that we'll insert the shapes into
    let pathSegments = (Int(0)..<Int(self._totalSegments)).compactMap({ index in
      return Piece(CGFloat(index), CGFloat(index) + 1, .space)
    })
    
    self._startDistance = self._totalLength * from
    
    switch direction {
    case .forward:
      self._segments = forward(pathSegments: pathSegments)
    case .backward:
      self._segments = backward(pathSegments: pathSegments)
    }

  }
  
}

// MARK: Layout

extension PathTraversal {
  
  private func forward(pathSegments: [Piece]) -> [Segment] {
    
    var shapes: [Piece] = []
    
    let accumulatingDistance: CGFloat = self._startDistance
    
    shapes.append(Piece(0, accumulatingDistance, .space))
    
    
    
    let ornamentEvery: CGFloat
    switch distribution {
    case .evenly:
      ornamentEvery = (self._totalLength) / CGFloat(self.itemCount)
      
      for position in stride(from: 0, to: self._totalLength, by: ornamentEvery) {
        shapes.append(Piece(position + accumulatingDistance, .shape))
      }
      
    case .continuous:

      for item in 0..<self.itemCount {
        shapes.append(Piece((CGFloat(item) * (spacing + divisionByZeroMin)) + accumulatingDistance, .shape))
      }
      
    }
    
    return SegmentSlicer.slice(pathSegments, shapes)
    
  }

  private func backward(pathSegments: [Piece]) -> [Segment] {
    
    var shapes: [Piece] = []
    
    let accumulatingDistance: CGFloat = self._startDistance
    
    let ornamentEvery: CGFloat
    switch distribution {
    case .evenly:
      ornamentEvery = (self._totalLength) / CGFloat(self.itemCount)
      
      for position in stride(from: self._totalLength, to: 0, by: ornamentEvery) {
        shapes.append(Piece(position - accumulatingDistance, .shape))
      }

    case .continuous:

      for item in (0..<self.itemCount).reversed() {
        shapes.append(Piece((self._totalLength) - (CGFloat(item) * (spacing + divisionByZeroMin)) - accumulatingDistance, .shape))
      }
      
    }

    return SegmentSlicer.slice(pathSegments, shapes)
    
  }

}

// MARK: Traverse

extension PathTraversal {
  
  typealias event = (Path.Element, Item) -> ()
  
  struct Item {
    let lastPoint: CGPoint
    let newPoint: CGPoint
    let angle: Angle
    let leftNormal: CGPoint
    let index: Int
  }
  
  func traverse(callback: event) {
    
    //let size: CGSize = CGSize(width: 100, height: 100)
    var startPoint: CGPoint = .zero
    var lastPoint: CGPoint = .zero
    
    var viewIndex: Int = 0
    var index: Int = 0
    
    var segmentCounter: Int = 0
    
    path.forEach { element in
      switch element {
      case .move(to: let point):
        
        startPoint = point
        lastPoint = point
        
        callback(.move(to: point), Item(lastPoint: lastPoint, newPoint: point, angle: .zero, leftNormal: .zero, index: index))

      case .line(to: let point):

        let segment = self._segments[segmentCounter]
        
        var tempLast = lastPoint
        for piece in segment.pieces {
          
          guard piece.type == .shape else {
            continue
          }
          
          let e = piece.start - CGFloat(segmentCounter)
          
          let newCGPoint = mix(SIMD2<Float>(lastPoint), SIMD2<Float>(point), t: Float(e))

          let angleInDegrees = tempLast.angle(between: newCGPoint.cgPoint)

          let newPoint = newCGPoint.cgPoint //* size

          

          guard viewIndex < itemCount else {
            return
          }
          
          let leftNormal = (newCGPoint.cgPoint - tempLast).normalize().rotateLeft() * 10

          callback(.line(to: point), Item(lastPoint: tempLast, newPoint: newPoint, angle: Angle(degrees: angleInDegrees), leftNormal: leftNormal, index: viewIndex))
          index += 1
          viewIndex += 1
          tempLast = newCGPoint.cgPoint
        }
        
        lastPoint = point
        segmentCounter += 1
      case .curve(to: let point, control1: let control1, control2: let control2):
        
        let arcLengths = Bezier.bezier_arcLengths(start: lastPoint, p1: control1, p2: control2, finish: point, accuracy: self.accuracy)

        let segment = self._segments[segmentCounter]
        
        var tempLast = lastPoint
        for piece in segment.pieces {
          
          guard piece.type == .shape else {
            continue
          }
          
          let e = Bezier.bezier_evenlyDistributed(u: piece.start - CGFloat(segmentCounter), arcLengths: arcLengths)
          
          let x = Bezier.bezier_point_x(t: e, a: lastPoint, b: control1, c: control2, d: point)
          let y = Bezier.bezier_point_y(t: e, a: lastPoint, b: control1, c: control2, d: point)

          let angleInDegrees = tempLast.angle(between: CGPoint(x: x, y: y))

          let newPoint = CGPoint(x: x, y: y) //* size

          

          guard viewIndex < itemCount else {
            return
          }
          
          let leftNormal = (newPoint - tempLast).normalize().rotateLeft() * 10

          callback(.curve(to: point, control1: control1, control2: control2), Item(lastPoint: tempLast, newPoint: newPoint, angle: Angle(degrees: angleInDegrees), leftNormal: leftNormal, index: viewIndex))
          index += 1
          viewIndex += 1
          tempLast = CGPoint(x: x, y: y)
        }
        
        lastPoint = point
        segmentCounter += 1
      case .quadCurve(to: let point, control: let control):

        let arcLengths = Bezier.bezier_arcLengths(start: lastPoint, p1: control, p2: control, finish: point, accuracy: self.accuracy)

        let segment = self._segments[segmentCounter]
        
        var tempLast = lastPoint
        for piece in segment.pieces {
          
          guard piece.type == .shape else {
            continue
          }
          
          let e = Bezier.bezier_evenlyDistributed(u: piece.start - CGFloat(segmentCounter), arcLengths: arcLengths)
          
          let x = Bezier.bezier_point_x(t: e, a: lastPoint, b: control, c: control, d: point)
          let y = Bezier.bezier_point_y(t: e, a: lastPoint, b: control, c: control, d: point)

          let angleInDegrees = tempLast.angle(between: CGPoint(x: x, y: y))

          let newPoint = CGPoint(x: x, y: y) //* size

          

          guard viewIndex < itemCount else {
            return
          }
          
          let leftNormal = (newPoint - tempLast).normalize().rotateLeft() * 10

          callback(.quadCurve(to: point, control: control), Item(lastPoint: tempLast, newPoint: newPoint, angle: Angle(degrees: angleInDegrees), leftNormal: leftNormal, index: viewIndex))
          index += 1
          viewIndex += 1
          tempLast = CGPoint(x: x, y: y)
        }
        
        lastPoint = point
        segmentCounter += 1
      case .closeSubpath:
        
        let segment = self._segments[segmentCounter]
        
        var tempLast = lastPoint
        for piece in segment.pieces {
          
          guard piece.type == .shape else {
            continue
          }
          
          let e = piece.start - CGFloat(segmentCounter)
          
          let newCGPoint = mix(SIMD2<Float>(lastPoint), SIMD2<Float>(startPoint), t: Float(e))

          let angleInDegrees = tempLast.angle(between: newCGPoint.cgPoint)

          let newPoint = newCGPoint.cgPoint //* size

          

          guard viewIndex < itemCount else {
            return
          }
          
          let leftNormal = (newPoint - tempLast).normalize().rotateLeft() * 10

          callback(.line(to: startPoint), Item(lastPoint: tempLast, newPoint: newPoint, angle: Angle(degrees: angleInDegrees), leftNormal: leftNormal, index: viewIndex))
          index += 1
          viewIndex += 1
          tempLast = newCGPoint.cgPoint
        }
        
        
        segmentCounter += 1
      }
      
    }
    
  }
  
}
