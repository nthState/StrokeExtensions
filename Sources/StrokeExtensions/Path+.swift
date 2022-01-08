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

extension Path {
  
  /// Total length of the path and how many segments it contains
  func totalLengthAndSegments(accuracy: UInt = 100) -> (length: CGFloat, segments: UInt) {
    
    var accumulatedLength: CGFloat = 0
    var segments: UInt = 0
    var lastPoint: CGPoint = .zero
    var startPoint: CGPoint?
    
    self.forEach { element in
      switch element {
      case .move(to: let point):
        lastPoint = point
        
        guard startPoint == nil else {
          return
        }
        
        startPoint = point
        
      case .line(to: let point):
        
        accumulatedLength += lastPoint.distance(to: point)
        
        segments += 1
        lastPoint = point
      case .curve(to: let point, control1: let control1, control2: let control2):
        
        accumulatedLength += bezier_length(start: lastPoint, p1: control1, p2: control2, finish: point, accuracy: accuracy)
        
        segments += 1
        lastPoint = point
      case .quadCurve(to: let point, control: _):
        
        segments += 1
        lastPoint = point
      case .closeSubpath:
        
        guard let startPoint = startPoint else {
          return
        }
        
        accumulatedLength += lastPoint.distance(to: startPoint)
        
        segments += 1
      }
    }
    
    return (accumulatedLength, segments)
  }
  
}
