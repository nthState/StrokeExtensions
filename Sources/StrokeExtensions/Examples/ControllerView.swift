//
//  ControllerView.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/main/LICENSE for license information.
//

import SwiftUI

struct ControllerView {
  
  @Binding var isAnimating: Bool
  @Binding var numberOfOrnaments: Double
  @Binding var offset: CGFloat
  @Binding var spacing: CGFloat
  @Binding var distribution: Distribution
  @Binding var direction: Direction
  @Binding var useXNormal: Bool
  @Binding var useYNormal: Bool

}

extension ControllerView: View {
  
  var body: some View {
    content
  }
  
  var content: some View {
    VStack {
      
      HStack {
        Text("Item Count")
          .frame(width: 100, alignment: .leading)
        Slider(value: $numberOfOrnaments, in: 0...30.0)
        TextField("", value: $numberOfOrnaments, formatter: NumberFormatter())
      }
      
      HStack {
        Text("From")
          .frame(width: 100, alignment: .leading)
        Slider(value: $offset, in: 0...1)
        TextField("", value: $offset, formatter: NumberFormatter())
      }
      
      HStack {
        Text("Spacing")
          .frame(width: 100, alignment: .leading)
        Slider(value: $spacing, in: 0...1)
        TextField("", value: $spacing, formatter: NumberFormatter())
      }
      
      HStack {
        Toggle("Flip X Normal", isOn: $useXNormal)
      }
      
      HStack {
        Toggle("Flip Y Normal", isOn: $useYNormal)
      }
      
      HStack {
        Button {
          switch distribution {
          case .continuous:
            distribution = .evenly
          case .evenly:
            distribution = .continuous
          }
        } label: {
          Text("Distribution: \(distribution.description)")
        }
        .frame(width: 120)
        .padding()
        .background(Color.green)
        
        Button {
          switch direction {
          case .forward:
            direction = .backward
          case .backward:
            direction = .forward
          }
        } label: {
          Text("Direction: \(direction.description)")
        }
        .frame(width: 120)
        .padding()
        .background(Color.green)
        
      }
    }
    .padding()
    .background(Color.blue.opacity(0.1))
    .cornerRadius(50)
  }
  
}

struct ControllerView_Previews: PreviewProvider {
  static var previews: some View {
    ControllerView(isAnimating: .constant(false),
                   numberOfOrnaments: .constant(10),
                   offset: .constant(1),
                   spacing: .constant(0),
                   distribution: .constant(.continuous),
                   direction: .constant(.forward),
                   useXNormal: .constant(true),
                   useYNormal: .constant(true))
  }
}
