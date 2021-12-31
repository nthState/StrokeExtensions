//
//  File.swift
//  
//
//  Created by Chris Davis on 30/12/2021.
//

import CoreGraphics
import SwiftUI

extension Path {
  
  /// Total length of the path
  func totalLength(accuracy: UInt = 100) -> (length: CGFloat, sections: UInt) {
    
    var accumulatedLength: CGFloat = 0
    var sections: UInt = 0
    var lastPoint: CGPoint = .zero
    var startPoint: CGPoint?
    
    self.forEach { element in
      switch element {
      case .move(to: let point):
        lastPoint = point
        
        guard startPoint != nil else {
          return
        }
        
        startPoint = point
        
      case .line(to: let point):
        
        accumulatedLength += lastPoint.distance(to: point)
        sections += 1
        lastPoint = point
      case .curve(to: let point, control1: let control1, control2: let control2):
        
        accumulatedLength += bezier_length(start: lastPoint, p1: control1, p2: control2, finish: point, accuracy: accuracy)
        
        lastPoint = point
      case .quadCurve(to: let point, control: let control):
        //context.draw(r0, at: point * size)
        sections += 1
        lastPoint = point
      case .closeSubpath:
        
        guard let startPoint = startPoint else {
          return
        }
        
        
        accumulatedLength += lastPoint.distance(to: startPoint)
        
        sections += 1
      }
    }
    
    return (accumulatedLength, sections)
  }
  
}
