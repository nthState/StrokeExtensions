//
//  CGPoint+.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/main/LICENSE for license information.
//

import CoreGraphics

public extension CGPoint {
  
  static func * (point: CGPoint, size: CGSize) -> CGPoint {
    return CGPoint(x: point.x * size.width, y: point.y * size.height)
  }
  
}

internal extension CGPoint {
  
  static func * (point: CGPoint, size: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * size, y: point.y * size)
  }

  static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
  }
  
  static func / (point: CGPoint, size: CGSize) -> CGPoint {
    return CGPoint(x: point.x / size.width, y: point.y / size.height)
  }
  
  func magnitude() -> CGFloat {
    return sqrt(x * x + y * y)
  }
  
  func distance(to: CGPoint) -> CGFloat {
    return CGPoint(x: to.x - x, y: to.y - y).magnitude()
  }
  
  func angle(between finishPoint: CGPoint) -> CGFloat {
    let center = CGPoint(x: finishPoint.x - self.x, y: finishPoint.y - self.y)
    let radians = atan2(center.y, center.x)
    let degrees = radians * 180 / .pi
    return degrees > 0 ? degrees : degrees + degrees
  }
  
  func normalize() -> CGPoint {
    let s = 1.0 / magnitude()
    return self * s
  }
  
  func rotateLeft() -> CGPoint {
    CGPoint(x: -self.y, y: self.x)
  }
}

