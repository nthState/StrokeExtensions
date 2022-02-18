//
//  CurveSwiftUIView.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/main/LICENSE for license information.
//

import SwiftUI

struct TextOnCurveSwiftUIView {
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
  
  func getCharacter(_ str: String, at index: Int) -> String? {
    guard str.count > 0 && index < str.count else { return nil }
    return String(str[String.Index.init(utf16Offset: index, in: str)])
  }
}

extension TextOnCurveSwiftUIView: View {
  var body: some View {
    VStack(spacing: 24) {
      Text("Text Example")
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
      
      Bunting()
        .stroke(Color.red, lineWidth: 1)
        .frame(width: 100, height: 100)
      
      Bunting()
        .stroke(itemCount: numberOfOrnaments, from: offset, spacing: spacing, distribution: distribution, direction: direction) { idx, layout in
          
          let scaled = layout.position * CGSize(width: 100, height: 100)
          
          if let character = getCharacter("Chris Davis is super-cool", at: Int(idx)) {
            
            Text(character)
              .scaleEffect(x: useXNormal ? (layout.leftNormal.y < 0 ? -1 : 1) : 1,
                           y: useYNormal ? (layout.leftNormal.y < 0 ? -1 : 1) : 1, anchor: UnitPoint.center)
              .rotationEffect(layout.angle)
              .position(x: scaled.x, y: scaled.y)
            
          } else {
            EmptyView()
          }

        }
        .background(Color.red.opacity(0.2))
        .frame(width: 100, height: 100)
      
    }
  }
  
  
  
}

struct TextOnCurveSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
      TextOnCurveSwiftUIView()
    }
}
