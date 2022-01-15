//
//  BuntingShape.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/main/LICENSE for license information.
//

import SwiftUI

struct Bunting: Shape {
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    
    path.move(to: .zero)
    path.addCurve(to: CGPoint(x: rect.maxX, y: rect.maxY/5),
                  control1: CGPoint(x: rect.midX, y: rect.maxY/3),
                  control2: CGPoint(x: rect.midX, y: rect.maxY/3))
    path.addCurve(to: CGPoint(x: rect.minX, y: rect.maxY/2),
                  control1: CGPoint(x: rect.midX, y: rect.maxY/1.9),
                  control2: CGPoint(x: rect.midX, y: rect.maxY/1.9))
    path.addCurve(to: CGPoint(x: rect.maxX, y: rect.maxY/1.5),
                  control1: CGPoint(x: rect.maxX, y: rect.maxY/1.2),
                  control2: CGPoint(x: rect.maxX, y: rect.maxY/1.5))
    //path.closeSubpath()
    
    return path
  }
  
}

struct Bunting_Previews: PreviewProvider {
    static var previews: some View {
      Bunting()
        .stroke(Color.red, lineWidth: 2)
        .frame(width: 100, height: 100)
    }
}
