import SwiftUI
import StrokeExtensions

struct ExampleSwiftUIView {
  
  func getCharacter(_ str: String, at index: Int) -> String? {
    guard str.count > 0 && index < str.count else { return nil }
    return String(str[String.Index.init(utf16Offset: index, in: str)])
  }
  
}

extension ExampleSwiftUIView: View {
  
  var body: some View {
    content
  }
  
  var content: some View {
    Rectangle()
      .stroke(itemCount: 12) { _, layout in
        
        let scaled = layout.position * CGSize(width: 100, height: 100)
        
        Circle()
          .fill(Color.red)
          .frame(width: 20, height: 20)
          .offset(x: scaled.x/2, y: scaled.y/2)
          .position(x: scaled.x/2, y: scaled.y/2)
        
      }
      .background(Rectangle().fill(.green))
      .frame(width: 100, height: 100)
  }
  
}
