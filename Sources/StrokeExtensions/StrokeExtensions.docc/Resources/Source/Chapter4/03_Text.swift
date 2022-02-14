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
      .stroke(itemCount: 12) { index, layout in
        
        let scaled = layout.position * CGSize(width: 100, height: 100)
        
        if let character = getCharacter("Hello, World", at: Int(index)) {
          
          Text(character)
            .position(x: scaled.x, y: scaled.y)
          
        } else {
          EmptyView()
        }
        
      }
      .background(Rectangle().fill(.green))
      .frame(width: 100, height: 100)
  }
  
}
