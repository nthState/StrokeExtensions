//
//  File.swift
//  
//
//  Created by Chris Davis on 30/12/2021.
//

import CoreGraphics

extension SIMD2 where Scalar == Float {
  init(_ point: CGPoint) {
    self.init(Float(point.x), Float(point.y))
  }
  
  var cgPoint: CGPoint {
    CGPoint(x: CGFloat(x), y: CGFloat(y))
  }
}
