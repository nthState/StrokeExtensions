//
//  SwiftUIView.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/main/LICENSE for license information.
//

import SwiftUI

struct SwiftUIView {
  
  func getCharacter(_ str: String, at index: Int) -> String? {
    guard str.count > 0 && index < str.count else { return nil }
    return String(str[String.Index.init(utf16Offset: index, in: str)])
  }
  
}

extension SwiftUIView: View {
  
  var body: some View {
    content
  }
  
  var content: some View {
    Rectangle()
      .stroke(itemCount: 10) { index, layout in
        
        let scaled = layout.position * CGSize(width: 100, height: 100)
        
        if let character = getCharacter("Hello, World", at: Int(index)) {
          
          Text(character)
            .scaleEffect(x: (layout.leftNormal.y < 0 ? -1 : 1),
                         y: (layout.leftNormal.y < 0 ? -1 : 1),
                         anchor: UnitPoint.center)
            .rotationEffect(layout.angle)
            .position(x: scaled.x, y: scaled.y)
          
        } else {
          EmptyView()
        }
        
      }
      .background(Rectangle().fill(.green))
      .frame(width: 100, height: 100)
  }
  
  
  
}


struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
