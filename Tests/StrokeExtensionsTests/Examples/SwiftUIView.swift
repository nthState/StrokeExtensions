//
//  SwiftUIView.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/master/LICENSE for license information.
//

import SwiftUI
import StrokeExtensions

struct SwiftUIView: View {
    var body: some View {
      ZStack {
        Curve()
          .stroke(itemCount: 10, from: 0, spacing: 0, distribution: .evenly, spawn: .forward, accuracy: 100) { index, layout in
            Circle()
              .fill(Color.orange)
              .frame(width: 10, height: 10)
          }
      }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
