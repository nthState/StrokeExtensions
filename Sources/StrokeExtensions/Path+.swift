//
//  Path+.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/master/LICENSE for license information.
//

import CoreGraphics
import SwiftUI

internal extension Path {
  
  /// Total length of the path and how many segments it contains
  func totalLengthAndSegments(accuracy: UInt = 100) -> (length: CGFloat, segments: UInt, lengths: [CGFloat]) {
    
    var accumulatedLength: CGFloat = 0
    var segments: UInt = 0
    var lastPoint: CGPoint = .zero
    var startPoint: CGPoint?
    var lengths: [CGFloat] = []
    
    self.forEach { element in
      switch element {
      case .move(to: let point):
        lastPoint = point
        
        guard startPoint == nil else {
          return
        }
        
        startPoint = point
        
      case .line(to: let point):
        
        let dist = lastPoint.distance(to: point)
        accumulatedLength += dist
        lengths.append(dist)
        
        segments += 1
        lastPoint = point
      case .curve(to: let point, control1: let control1, control2: let control2):
        
        let dist = Bezier.bezier_length(start: lastPoint, p1: control1, p2: control2, finish: point, accuracy: accuracy)
        accumulatedLength += dist
        lengths.append(dist)
        
        segments += 1
        lastPoint = point
      case .quadCurve(to: let point, control: let control):
        
        let dist = Bezier.bezier_length(start: lastPoint, p1: control, p2: control, finish: point, accuracy: accuracy)
        accumulatedLength += dist
        lengths.append(dist)
        
        segments += 1
        lastPoint = point
      case .closeSubpath:
        
        guard let startPoint = startPoint else {
          return
        }
        
        guard startPoint != lastPoint else {
          return
        }
        
        let dist = lastPoint.distance(to: startPoint)
        accumulatedLength += dist
        lengths.append(dist)
        
        segments += 1
      }
    }
    
    return (accumulatedLength, segments, lengths)
  }
  
}
