import SwiftUI
import StrokeExtensions

struct ExampleSwiftUIView {}

extension ExampleSwiftUIView: View {
  
  var body: some View {
    content
  }
  
  var content: some View {
    Circle()
      .background(Circle().fill(.green))
      .frame(width: 100, height: 100)
  }
  
}
