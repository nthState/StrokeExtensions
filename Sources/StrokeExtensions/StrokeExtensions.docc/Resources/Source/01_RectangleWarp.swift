
import SwiftUI

struct MyView: View {
  
  var body: some View {
    Rectangle()
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

