# StrokeKit

Adorn your SwiftUI Shapes/Beziers with Ornaments


Draw content along a bezier

```
public extension Shape {
  
  func stroke<NewContent>(itemCount: UInt = 1,
                          from: CGFloat = 0,
                          spacing: CGFloat = 0,
                          distribution: Distribution = .evenly,
                          spawn: Spawn = .forward,
                          accuracy: UInt = 100,
                          @ShapeContentBuilder innerContent: @escaping (UInt, LayoutData) -> NewContent) -> some View where NewContent : Ornamentable {
    modifier(OrnamentStyle(shape: self,
                           innerContent: innerContent,
                           itemCount: itemCount,
                           from: from,
                           spacing: spacing,
                           distribution: distribution,
                           spawn: spawn,
                           accuracy: accuracy))
  }
  
}

```

Draw content along a bezier using a `Canvas` as the backing buffer

```
public extension Shape {
  
  func strokeWithCanvas<NewContent>(itemCount: UInt = 1,
                                    from: CGFloat = 0,
                                    spacing: CGFloat = 0,
                                    distribution: Distribution = .evenly,
                                    spawn: Spawn = .forward,
                                    accuracy: UInt = 100,
                                    @ShapeContentBuilder innerContent: @escaping (UInt, LayoutData) -> NewContent) -> some View where NewContent : Ornamentable {
    modifier(OrnamentStyleWithCanvas(shape: self,
                                     innerContent: innerContent,
                                     itemCount: itemCount,
                                     from: from,
                                     spacing: spacing,
                                     distribution: distribution,
                                     spawn: spawn,
                                     accuracy: accuracy))
  }
  
}
```

TODO

- Triangle
- Bunting
- leftNormal
- spawn
- remove * size from code
- animation start stop
