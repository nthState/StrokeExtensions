//
//  SIMD2+.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/main/LICENSE for license information.
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
