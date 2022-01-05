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
  
  private let itemCount: UInt
  private let offsetPerItem: [CGPoint]
  private let from: CGFloat
  private let spacing: [CGFloat]
  private let layout: Layout
  private let accuracy: UInt
  
  private let _totalLength: CGFloat
  private let _totalSegments: UInt
  private let _centerPoint: CGFloat
  
  private var _startDistance: CGFloat = 0
  
  private var _items: [PathType] = []
  private var _segments: [Segment] = []
  
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
    
    self.offsetPerItem = offsetPerItem
    self.spacing = spacing
    self.from = from
    self.layout = layout
    self.accuracy = accuracy
    
    (self._totalLength, self._totalSegments) = self.path.totalLengthAndSegments()
    
    
    
    
    
    
//    let segments = [Segment(0, 1, .space), Segment(1, 2, .space)]
//    let shapes = [Segment(0.4, .shape), Segment(1.4, .shape)]
//
//    let actual: [Segment] = SegmentSlicer.slice(segments, shapes)
//
    let pathSegments = (Int(0)..<Int(self._totalSegments)).compactMap({ index in
      return Piece(CGFloat(index), CGFloat(index) + 1, .space)
    })
    
    
    
    
    
    
    
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
    
    var shapes: [Piece] = []
    
    let accumulatingDistance: CGFloat = self._startDistance
    
    //_items.append(.spacer(distance: accumulatingDistance))
    shapes.append(Piece(0, accumulatingDistance, .space))
    
    
    self.itemCount = itemCount ?? 10
    let ornamentEvery = (self._totalLength) / CGFloat(self.itemCount)
    
    
    for position in stride(from: 0, to: self._totalLength, by: ornamentEvery) {

      shapes.append(Piece(position + accumulatingDistance, .shape))
    }
    
    self._segments = SegmentSlicer.slice(pathSegments, shapes)
    
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
        
        callback(.move(to: point), Item(lastPoint: lastPoint, newPoint: point, angle: .zero, index: index))

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

          tempLast = newCGPoint.cgPoint

          guard viewIndex < itemCount else {
            return
          }

          callback(.line(to: point), Item(lastPoint: tempLast, newPoint: newPoint, angle: Angle(degrees: angleInDegrees), index: viewIndex))
          index += 1
          viewIndex += 1
          
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

          tempLast = CGPoint(x: x, y: y)

          guard viewIndex < itemCount else {
            return
          }

          callback(.curve(to: point, control1: control1, control2: control2), Item(lastPoint: tempLast, newPoint: newPoint, angle: Angle(degrees: angleInDegrees), index: viewIndex))
          index += 1
          viewIndex += 1
          
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

          tempLast = newCGPoint.cgPoint

          guard viewIndex < itemCount else {
            return
          }

          callback(.line(to: startPoint), Item(lastPoint: tempLast, newPoint: newPoint, angle: Angle(degrees: angleInDegrees), index: viewIndex))
          index += 1
          viewIndex += 1
          
        }
        
        
        segmentCounter += 1
      }
      
    }
    
  }
  
}
