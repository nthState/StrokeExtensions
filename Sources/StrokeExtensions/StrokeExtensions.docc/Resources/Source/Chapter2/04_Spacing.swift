import SwiftUI
import StrokeExtensions

struct ExampleSwiftUIView {}

extension ExampleSwiftUIView: View {
  
  var body: some View {
    content
  }
  
  var content: some View {
    Circle()
      .stroke(itemCount: 5, from: 0.2, spacing: 0.1, distribution: .continuous) { _, layout in
        
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
