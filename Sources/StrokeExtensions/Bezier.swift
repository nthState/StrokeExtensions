//
//  Bezier.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/master/LICENSE for license information.
//

import Foundation
import CoreGraphics

//class Bezier {

func _bezier_point(t: CGFloat,  start: CGFloat,  control_1: CGFloat, control_2: CGFloat, finish: CGFloat) -> CGFloat {
  return              start * (1.0 - t) * (1.0 - t)  * (1.0 - t)
  + 3.0 *  control_1 * (1.0 - t) * (1.0 - t)  * t
  + 3.0 *  control_2 * (1.0 - t) * t          * t
  +           finish * t         * t          * t
}

func _bezier_point_x(t: CGFloat, a: CGPoint, b: CGPoint, c: CGPoint, d: CGPoint) -> CGFloat {
  return ((1 - t) * (1 - t) * (1 - t)) * a.x
  + 3 * ((1 - t) * (1 - t)) * t * b.x
  + 3 * (1 - t) * (t * t) * c.x
  + (t * t * t) * d.x
}

func _bezier_point_y(t: CGFloat, a: CGPoint, b: CGPoint, c: CGPoint, d: CGPoint) -> CGFloat {
  return ((1 - t) * (1 - t) * (1 - t)) * a.y
  + 3 * ((1 - t) * (1 - t)) * t * b.y
  + 3 * (1 - t) * (t * t) * c.y
  + (t * t * t) * d.y
}

func bezier_length(start: CGPoint, p1: CGPoint,  p2: CGPoint, finish: CGPoint, accuracy: UInt) -> CGFloat {
  let by: CGFloat = 1.0 / CGFloat(accuracy)
  var dot: CGPoint = .zero
  var previous_dot: CGPoint = .zero
  var length: CGFloat = 0.0
  for item in stride(from: 0, to: 1, by: by) {
    dot.x = _bezier_point (t: item, start: start.x, control_1: p1.x, control_2: p2.x, finish: finish.x)
    dot.y = _bezier_point (t: item, start: start.y, control_1: p1.y, control_2: p2.y, finish: finish.y)
    if (item > 0) {
      let x_diff:CGFloat = dot.x - previous_dot.x;
      let y_diff:CGFloat = dot.y - previous_dot.y;
      length += sqrt (x_diff * x_diff + y_diff * y_diff);
    }
    previous_dot = dot;
  }
  return length;
  
}

func bezier_arcLengths(start: CGPoint, p1: CGPoint, p2: CGPoint, finish: CGPoint, accuracy: UInt) -> [CGFloat] {
  
  var clen:CGFloat = 0
  
  let by: CGFloat = 1.0 / CGFloat(accuracy)
  
  var ox:CGFloat = _bezier_point_x (t: 0, a: start, b: p1, c: p2, d: finish);
  var oy:CGFloat = _bezier_point_y (t: 0, a: start, b: p1, c: p2, d: finish);
  
  var arcLengths: [CGFloat] = []
  //arcLengths.append(0)
  for item in stride(from: by, to: 1, by: by) {
    let x = _bezier_point_x (t: item, a: start, b: p1, c: p2, d: finish)
    let y = _bezier_point_y (t: item, a: start, b: p1, c: p2, d: finish)
    let dx = ox - x, dy = oy - y;
    clen += sqrt(dx * dx + dy * dy);
    arcLengths.append(clen)
    ox = x
    oy = y
  }
  return arcLengths
}

func bezier_evenlyDistributed(u: CGFloat, arcLengths: [CGFloat]) -> CGFloat {
  let len = arcLengths.count - 1
  let targetLength = u * arcLengths[len]
  var low = 0
  var high = len
  var index = 0
  
  while (low < high) {
    index = low + (((high - low) / 2) | 0)
    if (arcLengths[index] < targetLength) {
      low = index + 1;
      
    } else {
      high = index;
    }
  }
  if (arcLengths[index] > targetLength) {
    index -= 1;
    if index < 0 {
      return 0
    }
  }
  
  let lengthBefore:CGFloat = arcLengths[index]
  if (lengthBefore == targetLength) {
    return CGFloat(index) / CGFloat(len)
    
  } else {
    return (CGFloat(index) + (targetLength - lengthBefore) / (arcLengths[index + 1] - lengthBefore)) / CGFloat(len)
  }
}



//}
