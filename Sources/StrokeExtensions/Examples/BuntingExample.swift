//
//  BuntingSwiftUIView.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/master/LICENSE for license information.
//

import SwiftUI

struct BuntingSwiftUIView {
  @State var isAnimating = false
  @State var numberOfOrnaments: Int = 3
  @State var offset: CGFloat = 0
  @State var spacing: CGFloat = 0.1
  @State var distribution: Distribution = .continuous
  @State var direction: Direction = .forward
  @State var useNormal: Bool = true
  
  var intProxy: Binding<Double>{
    Binding<Double>(get: {
      return Double(numberOfOrnaments)
    }, set: {
      numberOfOrnaments = Int($0)
    })
  }
}

extension BuntingSwiftUIView: View {
  
  var body: some View {
    VStack(spacing: 24) {
      Text("Bunting Example")
      curve
      controls
    }
  }
  
  var curve: some View {
    ZStack {
      
      Bunting()
        .stroke(Color.red, lineWidth: 1)
        .frame(width: 100, height: 100)
      
      Bunting()
        .stroke(itemCount: numberOfOrnaments, from: offset, spacing: spacing, distribution: distribution, direction: direction) { item, layout in
          
          let scaled = layout.position * CGSize(width: 100, height: 100)
          
          if item % 2 == 0 {
            
            Triangle()
              .fill(Color.green)
              .frame(width: 10, height: 10, alignment: .center)
              .rotationEffect(Angle(degrees: self.isAnimating ? 360.0 : 0.0))
              .scaleEffect(useNormal ? (layout.leftNormal.y < 0 ? -1 : 1) : 1)
              .scaleEffect(-1)
              .rotationEffect(layout.angle)
              .offset(x: scaled.x/2, y: scaled.y/2)
              .offset(y: 5)
              .position(x: scaled.x/2, y: scaled.y/2)
            
          } else {
            
            Rectangle()
              .fill(Color.blue)
              .frame(width: 5, height: 5, alignment: .center)
              .border(Color.black, width: 1)
              .rotationEffect(Angle(degrees: self.isAnimating ? 360.0 : 0.0))
              .rotationEffect(layout.angle)
              .position(scaled)
//              .offset(x: scaled.x/2, y: scaled.y/2)
//              .position(x: scaled.x/2, y: scaled.y/2)
            
          }
          
        }
        .frame(width: 100, height: 100)
      
    }
    .background(Color.yellow)
  }
  
  var controls: some View {
    VStack {
      
      HStack {
        Text("Flags")
          .frame(width: 100, alignment: .leading)
        Slider(value: intProxy, in: 0...30.0)
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
        Toggle("Use Normal", isOn: $useNormal)
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
        .padding()
        .background(Color.green)
        
      }
    }
    .padding()
    .background(Color.blue.opacity(0.1))
    .cornerRadius(50)
  }
  
}

struct BuntingSwiftUIView_Previews: PreviewProvider {
  static var previews: some View {
    BuntingSwiftUIView()
  }
}
