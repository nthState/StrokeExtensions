
import SwiftUI
import PathWarp

struct MyView: View {
  
  var body: some View {
    Rectangle()
      .warp(amount: 10, seed: 0987654321)
      .stroke(Color.red, lineWidth: 2)
      .frame(width: 100, height: 100)
  }
  
}

#if DEBUG
struct MyView_Preview: PreviewProvider {
  
  static var previews: some View {
    MyView()
  }
  
}
#endif
