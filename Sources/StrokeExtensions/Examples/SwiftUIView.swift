//
//  SwiftUIView.swift
//  
//
//  Created by Chris Davis on 12/02/2022.
//

import SwiftUI

struct SwiftUIView {}

extension SwiftUIView: View {
  
  var body: some View {
    content
  }
  
  var content: some View {
    Circle()
      .stroke(itemCount: 3) { _, layout in
        
        let scaled = layout.position * CGSize(width: 100, height: 100)
        
        Circle()
          .fill(Color.red)
          .frame(width: 20, height: 20)
          .offset(x: scaled.x/2, y: scaled.y/2)
          .position(x: scaled.x/2, y: scaled.y/2)
        
      }
      .background(Circle().fill(.green))
      .frame(width: 100, height: 100)
  }
  
  
  
}


struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
