# StrokeKit

Adorn your SwiftUI Shapes/Beziers with Ornaments


Draw content along a bezier

```
public extension Shape {
  
  func stroke<NewContent>(itemCount: UInt? = nil,
                          from: CGFloat = 0,
                          offsetPerItem: [CGPoint] = [],
                          spacing: [CGFloat] = [],
                          layout: Layout = .clockwise,
                          rotateToPath: Bool = true,
                          accuracy: UInt = 100,
                          @ShapeContentBuilder innerContent: @escaping (UInt, LayoutData) -> NewContent) -> some View where NewContent : Ornamentable {
    modifier(OrnamentStyle(shape: self,
                           innerContent: innerContent,
                           itemCount: itemCount,
                           from: from,
                           offsetPerItem: offsetPerItem,
                           spacing: spacing,
                           layout: layout,
                           rotateToPath: rotateToPath,
                           accuracy: accuracy))
  }
  
}
```

Draw content along a bezier using a `Canvas` as the backing buffer

```
public extension Shape {
  
  func strokeWithCanvas<NewContent>(itemCount: UInt? = nil,
                                    from: CGFloat = 0,
                                    offsetPerItem: [CGPoint] = [],
                                    spacing: [CGFloat] = [],
                                    layout: Layout = .clockwise,
                                    rotateToPath: Bool = true,
                                    accuracy: UInt = 100,
                                    @ShapeContentBuilder innerContent: @escaping (UInt, LayoutData) -> NewContent) -> some View where NewContent : Ornamentable {
    modifier(OrnamentStyleWithCanvas(shape: self,
                                     innerContent: innerContent,
                                     itemCount: itemCount,
                                     from: from,
                                     offsetPerItem: offsetPerItem,
                                     spacing: spacing,
                                     layout: layout,
                                     rotateToPath: rotateToPath,
                                     accuracy: accuracy))
  }
  
}
```

