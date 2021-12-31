//
//  File.swift
//  
//
//  Created by Chris Davis on 30/12/2021.
//

import Foundation
import SwiftUI

/// 90 degree corner curve
struct Curve: Shape {
  
  var start: CGFloat = 0
  var finish: CGFloat = 1
  
  func path(in rect: CGRect) -> Path {
    
    let p = Path { path in
      path.move(to: .zero)
      path.addCurve(to: CGPoint(x: rect.size.width, y: rect.size.height),
                    control1: CGPoint(x: rect.size.width, y: 0),
                    control2: CGPoint(x: rect.size.width, y: 0))
    }
    
    return p
      .trimmedPath(from: start, to: finish)
  }
  
  var animatableData: AnimatablePair<CGFloat, CGFloat> {
    get { AnimatablePair(start, finish) }
    set { (start, finish) = (newValue.first, newValue.second) }
  }
  
}
