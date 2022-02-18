//
//  CanvasSwiftUIView.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/main/LICENSE for license information.
//

import SwiftUI

struct CanvasSwiftUIView {
  @State var isAnimating = false
  @State var numberOfOrnaments: Int = 3
  @State var offset: CGFloat = 0
  @State var spacing: CGFloat = 0.1
  @State var distribution: Distribution = .continuous
  @State var direction: Direction = .forward
  @State var useXNormal: Bool = true
  @State var useYNormal: Bool = true
  
  var intProxy: Binding<Double>{
    Binding<Double>(get: {
      return Double(numberOfOrnaments)
    }, set: {
      numberOfOrnaments = Int($0)
    })
  }
}

extension CanvasSwiftUIView: View {
  
  var body: some View {
    VStack {
      Text("Canvas Example")
      curve
      ControllerView(isAnimating: $isAnimating,
                     numberOfOrnaments: intProxy,
                     offset: $offset,
                     spacing: $spacing,
                     distribution: $distribution,
                     direction: $direction,
                     useXNormal: $useXNormal,
                     useYNormal: $useYNormal)
    }
  }
  
  var curve: some View {
    ZStack {
      
      Curve()
        .stroke(Color.red, lineWidth: 1)
        .frame(width: 100, height: 100)
      
      Curve()
        .strokeWithCanvas(itemCount: numberOfOrnaments, from: offset, spacing: spacing, distribution: distribution, direction: direction, size: CGSize(width: 100, height: 100)) { item, _ in
          
          if item % 2 == 0 {
            
            Circle()
              .fill(Color.blue)
              .frame(width: 10, height: 10)
            
          } else {
            
            Circle()
              .fill(Color.red)
              .frame(width: 20, height: 20)
            
          }
          
        }
        .frame(width: 100, height: 100)
      
    }
    .background(Color.yellow)
  }
  
}

struct CanvasSwiftUIView_Previews: PreviewProvider {
  static var previews: some View {
    CanvasSwiftUIView()
  }
}
