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

public class PathTraversal<S> where S: Shape {
  
  private let path: Path
  
  private let itemCount: UInt
  private let from: CGFloat
  private let spacing: CGFloat
  private let distribution: Distribution
  private let spawn: Spawn
  private let accuracy: UInt
  
  private let divisionByZeroMin: CGFloat = 0.0001
  
  private let _totalLength: CGFloat
  private let _totalSegments: UInt
  
  private var _startDistance: CGFloat = 0
  
  private var _items: [PathType] = []
  private var _segments: [Segment] = []
  
  public init(shape: S,
              itemCount: UInt = 1,
              from: CGFloat = 0,
              spacing: CGFloat = 0,
              distribution: Distribution = .evenly,
              spawn: Spawn = .forward,
              accuracy: UInt = 100) {
    
    precondition(from >= 0 && from <= 1, "From must be a percentage in range 0.0 to 1.0")
    
    self.path = shape.path(in: CGRect.unit)
    
    
    self.spacing = spacing
    self.from = from
    self.distribution = distribution
    self.spawn = spawn
    self.accuracy = accuracy
    self.itemCount = itemCount
    
    (self._totalLength, self._totalSegments) = self.path.totalLengthAndSegments()
    
    
    // Create an array of segments that we'll insert the shapes into
    let pathSegments = (Int(0)..<Int(self._totalSegments)).compactMap({ index in
      return Piece(CGFloat(index), CGFloat(index) + 1, .space)
    })
    
    self._startDistance = self._totalLength * from
    
    switch spawn {
    case .forward:
      self._segments = forward(pathSegments: pathSegments)
    case .backward:
      self._segments = backward(pathSegments: pathSegments.reversed())
    }

  }
  
}

// MARK: Layout

public extension PathTraversal {
  
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

      for item in 0..<self.itemCount {
        shapes.append(Piece(1 - (CGFloat(item) * (spacing + divisionByZeroMin)) - accumulatingDistance, .shape))
      }
      
    }

    return SegmentSlicer.slice(pathSegments, shapes)
    
  }

}

// MARK: Traverse

public extension PathTraversal {
  
  typealias event = (Path.Element, Item) -> ()
  
  struct Item {
    let lastPoint: CGPoint
    let newPoint: CGPoint
    let angle: Angle
    let leftNormal: CGPoint
    let index: Int
  }
  
  func traverse(callback: event) {
    
    let size: CGSize = CGSize(width: 100, height: 100)
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

          let newPoint = newCGPoint.cgPoint * size

          

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
        
        //let curveLength = bezier_length(start: lastPoint, p1: control1, p2: control2, finish: point, accuracy: self.accuracy)
        let arcLengths = bezier_arcLengths(start: lastPoint, p1: control1, p2: control2, finish: point, accuracy: self.accuracy)

        let segment = self._segments[segmentCounter]
        
        var tempLast = lastPoint
        for piece in segment.pieces {
          
          guard piece.type == .shape else {
            continue
          }
          
          let e = bezier_evenlyDistributed(u: piece.start - CGFloat(segmentCounter), arcLengths: arcLengths)
          
          let x = _bezier_point_x(t: e, a: lastPoint, b: control1, c: control2, d: point)
          let y = _bezier_point_y(t: e, a: lastPoint, b: control1, c: control2, d: point)

          let angleInDegrees = tempLast.angle(between: CGPoint(x: x, y: y))

          let newPoint = CGPoint(x: x, y: y) * size

          

          guard viewIndex < itemCount else {
            return
          }
          
          let leftNormal = (newPoint - tempLast).normalize().rotateLeft()

          callback(.curve(to: point, control1: control1, control2: control2), Item(lastPoint: tempLast, newPoint: newPoint, angle: Angle(degrees: angleInDegrees), leftNormal: leftNormal, index: viewIndex))
          index += 1
          viewIndex += 1
          tempLast = CGPoint(x: x, y: y)
        }
        
        segmentCounter += 1
      case .quadCurve(to: let point, control: _):
#warning("UNIMPLEMENTED - Chris to add")
        lastPoint = point
        index += 1
        viewIndex += 1
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

          let newPoint = newCGPoint.cgPoint * size

          

          guard viewIndex < itemCount else {
            return
          }
          
          let leftNormal = (newPoint - tempLast).normalize().rotateLeft()

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
