//
//  CurveSwiftUIView.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/master/LICENSE for license information.
//

import SwiftUI

struct TextOnCurveSwiftUIView {
  @State var isAnimating = false
  @State var numberOfOrnaments: Int = 3
  @State var offset: CGFloat = 0
  @State var spacing: CGFloat = 0.1
  @State var distribution: Distribution = .continuous
  @State var spawn: Spawn = .forward
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
      controls
    }
  }
  
  var curve: some View {
    ZStack {
      
      Bunting()
        .stroke(Color.red, lineWidth: 1)
        .frame(width: 100, height: 100)
      
      Bunting()
        .stroke(itemCount: numberOfOrnaments, from: offset, spacing: spacing, distribution: distribution, spawn: spawn) { idx, layout in
          
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
  
  var controls: some View {
    VStack {
      
      HStack {
        Text("Letter Count")
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
    .padding()
    .background(Color.blue.opacity(0.1))
    .cornerRadius(50)
  }
  
}

struct TextOnCurveSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
      TextOnCurveSwiftUIView()
    }
}
