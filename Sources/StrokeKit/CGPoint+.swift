//
//  File.swift
//  
//
//  Created by Chris Davis on 30/12/2021.
//

import CoreGraphics

extension CGPoint {
  
  static func * (point: CGPoint, size: CGSize) -> CGPoint {
    return CGPoint(x: point.x * size.width, y: point.y * size.height)
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
}

