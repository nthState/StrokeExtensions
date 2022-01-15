//
//  CanvasSwiftUIView.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/master/LICENSE for license information.
//

import SwiftUI

struct CanvasSwiftUIView {
  @State var isAnimating = false
  @State var numberOfOrnaments: Int = 3
  @State var offset: CGFloat = 0
  @State var spacing: CGFloat = 0.1
  @State var distribution: Distribution = .continuous
  @State var spawn: Spawn = .forward
  
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
      controls
    }
  }
  
  var curve: some View {
    ZStack {
      
      Curve()
        .stroke(Color.red, lineWidth: 1)
        .frame(width: 100, height: 100)
      
      Curve()
        .strokeWithCanvas(itemCount: numberOfOrnaments, from: offset, spacing: spacing, distribution: distribution, spawn: spawn, size: CGSize(width: 100, height: 100)) { item, _ in
          
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
  
  var controls: some View {
    VStack {
      
      HStack {
        Text("Ornaments")
        Slider(value: intProxy, in: 0...30.0)
        TextField("", value: $numberOfOrnaments, formatter: NumberFormatter())
      }
      
      HStack {
        Text("From")
        Slider(value: $offset, in: 0...1)
        TextField("", value: $offset, formatter: NumberFormatter())
      }
      
      HStack {
        Text("Spacing")
        Slider(value: $spacing, in: 0...1)
        TextField("", value: $spacing, formatter: NumberFormatter())
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
          switch spawn {
          case .forward:
            spawn = .backward
          case .backward:
            spawn = .forward
          }
        } label: {
          Text("Spawn: \(spawn.description)")
        }
        .padding()
        .background(Color.green)
        
      }
    }
  }
  
}

struct CanvasSwiftUIView_Previews: PreviewProvider {
  static var previews: some View {
    CanvasSwiftUIView()
  }
}
