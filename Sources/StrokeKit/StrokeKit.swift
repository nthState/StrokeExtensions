import SwiftUI

public extension Shape {
  
  func stroke<NewContent>(itemCount: UInt? = nil,
                          direction: Direction = .rightToLeft,
                          spacing: [CGFloat] = [],
                          accuracy: UInt = 100,
                          @ViewBuilder innerContent: @escaping () -> NewContent) -> some View where NewContent : View {
    modifier(OrnamentStyle(shape: self,
                                     innerContent: innerContent,
                                     direction: direction,
                                     itemCount: itemCount,
                                     spacing: spacing,
                                     accuracy: accuracy))
  }
  
  func strokeWithCanvas<NewContent>(itemCount: UInt? = nil,
                                    direction: Direction = .rightToLeft,
                                    spacing: [CGFloat] = [],
                                    accuracy: UInt = 100,
                                    @ViewBuilder innerContent: @escaping () -> NewContent) -> some View where NewContent : View {
    modifier(OrnamentStyleWithCanvas(shape: self,
                                     innerContent: innerContent,
                                     direction: direction,
                                     itemCount: itemCount,
                                     spacing: spacing,
                                     accuracy: accuracy))
  }
  
}

public enum Direction {
  case rightToLeft
  case leftToRight
}
