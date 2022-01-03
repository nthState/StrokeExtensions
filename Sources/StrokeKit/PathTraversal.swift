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
  private let itemCount: UInt
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
  //private var _uuids: [UUID] = []
  
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
    //self.itemCount = itemCount
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
    
    var accumulatingDistance: CGFloat = self._startDistance
    
    _items.append(.spacer(distance: accumulatingDistance))
    
    
    self.itemCount = itemCount ?? 10
    let ornamentEvery = (self._totalLength) / CGFloat(self.itemCount)
    
    var ctr: Int = 0
    for _ in stride(from: 0, to: self._totalLength, by: ornamentEvery) {
      _items.append(.shape)
      //_uuids.append(UUID())
      accumulatingDistance += ornamentEvery
      _items.append(.spacer(distance: accumulatingDistance))
      if self.spacing.indices.contains(ctr) {
        _items.append(.spacer(distance: self.spacing[ctr]))
      }
      ctr += 1
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
    //let uuid: UUID
  }
  
  func traverse(callback: event) {
    
    let size: CGSize = CGSize(width: 100, height: 100)
    var startPoint: CGPoint = .zero
    var lastPoint: CGPoint = .zero
    
    var viewIndex: Int = 0
    var index: Int = 0
    var distanceTravelled: CGFloat = 0
    
    var varyingPercentage: CGFloat = 0
    
    path.forEach { element in
      switch element {
      case .move(to: let point):
        
        startPoint = point
        lastPoint = point
        distanceTravelled = 0
        
        callback(.move(to: point), Item(lastPoint: lastPoint, newPoint: point, angle: .zero, index: index))
        
        
      case .line(to: let point):
        
        let length = lastPoint.distance(to: point)
  
        let by: CGFloat = length / CGFloat(accuracy)
        
        var tempDistance = distanceTravelled
        
        var tempLast = lastPoint
        var zero: CGFloat = 0
        var idx: Int = 0
        for item in stride(from: 0, through: length, by: by) {
          
          switch _items[index] {
          case .spacer(distance: let dist):
            if (tempDistance + item - zero) >= dist {
              
              index += 1
              tempDistance += item
              zero = item
              
              varyingPercentage = item
              
              fallthrough
            }
          case .shape:
            //let r = varyingPercentage.truncatingRemainder(dividingBy: 1)
            let p = varyingPercentage// == 1 ? 1 : r
            let newCGPoint = mix(SIMD2<Float>(lastPoint), SIMD2<Float>(point), t: Float(p))
            
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
          
          idx += 1

        }
        
        
          distanceTravelled += length
        
        
        lastPoint = point
      case .curve(to: let point, control1: let control1, control2: let control2):
        
        let curveLength = bezier_length(start: lastPoint, p1: control1, p2: control2, finish: point, accuracy: self.accuracy)
        let arcLengths = bezier_arcLengths(start: lastPoint, p1: control1, p2: control2, finish: point, accuracy: self.accuracy)
        
        var tempDistance = distanceTravelled
        
        var tempLast = lastPoint
        var zero: CGFloat = 0
        for (idx, accumulatingLength) in arcLengths.enumerated() {
          
          switch _items[index] {
          case .spacer(distance: let dist):
            if (tempDistance + accumulatingLength - zero) >= dist {
              
              index += 1
              tempDistance = accumulatingLength
              zero = accumulatingLength
              
              varyingPercentage = accumulatingLength / curveLength
              
              //fallthrough
            }
          case .shape:
            //CGFloat(idx) / CGFloat(accuracy)
            //let r = varyingPercentage.truncatingRemainder(dividingBy: 1)
            let p = varyingPercentage //== 1 ? 1 : r
            
            let e = bezier_evenlyDistributed(u: p, arcLengths: arcLengths)
            
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
          
          
          
        }
        
   
          distanceTravelled += curveLength
        
        
        lastPoint = point
      case .quadCurve(to: let point, control: let control):
#warning("UNIMPLEMENTED - Chris to add")
        lastPoint = point
        index += 1
        viewIndex += 1
      case .closeSubpath:
//        let length = lastPoint.distance(to: startPoint)
//        let repeatCount = 10//self.itemCount ?? UInt((length * 100) / innerContentWidth)
//
//        let itemCount: CGFloat = CGFloat(repeatCount)
//        let by: CGFloat = 1 / itemCount
//
//        var tempLast = lastPoint
//        for item in stride(from: 0, through: 1, by: by) {
//
//          distanceTravelled += by
//          guard distanceTravelled >= self._startDistance else {
//            continue
//          }
//
//          let newCGPoint = mix(SIMD2<Float>(lastPoint), SIMD2<Float>(startPoint), t: Float(item))
//
//          let angleInDegrees = tempLast.angle(between: newCGPoint.cgPoint)
//
//          let newPoint = newCGPoint.cgPoint * size
//
//          tempLast = newCGPoint.cgPoint
//
//          callback(.closeSubpath, Item(lastPoint: tempLast, newPoint: newPoint, angle: Angle(degrees: angleInDegrees), index: viewIndex))
//
//          index += 1
//          viewIndex += 1
//        }
        
        let point = startPoint
        
        let length = lastPoint.distance(to: point)
  
        let by: CGFloat = length / CGFloat(accuracy)
        
        var tempDistance = distanceTravelled
        
        var tempLast = lastPoint
        var zero: CGFloat = 0
        var idx: Int = 0
        for item in stride(from: 0, through: length, by: by) {
          
          switch _items[index] {
          case .spacer(distance: let dist):
            if (tempDistance + item - zero) >=  dist {
              
              index += 1
              tempDistance += item
              zero = item
              
              varyingPercentage = item
              
              fallthrough
            }
          case .shape:
            //let r = varyingPercentage.truncatingRemainder(dividingBy: 1)
            let p = varyingPercentage //== 1 ? 1 : r
            
            let newCGPoint = mix(SIMD2<Float>(lastPoint), SIMD2<Float>(point), t: Float(p))
            
              let angleInDegrees = tempLast.angle(between: newCGPoint.cgPoint)
            
              let newPoint = newCGPoint.cgPoint * size
            
              tempLast = newCGPoint.cgPoint

            guard viewIndex < itemCount else {
              return
            }
            
            callback(.closeSubpath, Item(lastPoint: tempLast, newPoint: newPoint, angle: Angle(degrees: angleInDegrees), index: viewIndex))
            index += 1
            viewIndex += 1
          }
          
          idx += 1

        }
        
        
          distanceTravelled += length
        
        
        lastPoint = point
        
        
        
      }
      
      
    }
    
  }
  
}



//let length = bezier_length(start: lastPoint, p1: control1, p2: control2, finish: point, accuracy: self.accuracy)
//let lengths = bezier_arcLengths(start: lastPoint, p1: control1, p2: control2, finish: point, accuracy: self.accuracy)
//
//let repeatCount = 10//self.itemCount ?? UInt((length * 100) / innerContentWidth)
//
//let itemCount: CGFloat = CGFloat(repeatCount)
//let by: CGFloat = 1 / itemCount
//
//var tempLast = lastPoint
//for item in stride(from: 0, through: 1, by: by) {
//
//  let e = bezier_evenlyDistributed(u: item, arcLengths: lengths)
//
//  distanceTravelled += by
//  guard distanceTravelled >= self._startDistance else {
//    continue
//  }
//
//  let x = _bezier_point_x(t: e, a: lastPoint, b: control1, c: control2, d: point)
//  let y = _bezier_point_y(t: e, a: lastPoint, b: control1, c: control2, d: point)
//
//  let angleInDegrees = tempLast.angle(between: CGPoint(x: x, y: y))
//
//  let newPoint = CGPoint(x: x, y: y) * size
//
//  tempLast = CGPoint(x: x, y: y)
//
//  callback(.curve(to: point, control1: control1, control2: control2), Item(lastPoint: tempLast, newPoint: newPoint, angle: Angle(degrees: angleInDegrees), index: index))
//  index += 1
//}









//let length = lastPoint.distance(to: point)
//let repeatCount = 10//self.itemCount ?? UInt((length * 100) / innerContentWidth)
//
//let itemCount: CGFloat = CGFloat(repeatCount)
//let by: CGFloat = 1 / itemCount
//
//var tempLast = lastPoint
//for item in stride(from: 0, through: 1, by: by) {
//
//
//  distanceTravelled += by
//  guard distanceTravelled >= self._startDistance else {
//    continue
//  }
//
//  let newCGPoint = mix(SIMD2<Float>(lastPoint), SIMD2<Float>(point), t: Float(item))
//
//  let angleInDegrees = tempLast.angle(between: newCGPoint.cgPoint)
//
//  let newPoint = newCGPoint.cgPoint * size
//
//  tempLast = newCGPoint.cgPoint
//
//  callback(.line(to: point), Item(lastPoint: tempLast, newPoint: newPoint, angle: Angle(degrees: angleInDegrees), index: viewIndex))
//  index += 1
//  viewIndex += 1
//}
//
//
//lastPoint = point
