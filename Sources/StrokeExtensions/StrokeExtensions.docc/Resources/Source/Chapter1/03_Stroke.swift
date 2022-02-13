import SwiftUI
import StrokeExtensions

struct ExampleSwiftUIView {}

extension ExampleSwiftUIView: View {
  
  var body: some View {
    content
  }
  
  var content: some View {
    Circle()
      .stroke(itemCount: 3) { _, _ in

        Circle()
          .fill(Color.red)
          .frame(width: 20, height: 20)
        
      }
      .background(Circle().fill(.green))
      .frame(width: 100, height: 100)
  }
  
}
