# StrokeExtensions

Adorn your SwiftUI Shapes/Beziers with Ornaments





```
struct SwiftUIView: View {
    var body: some View {
      ZStack {
        Curve()
          .stroke(itemCount: 10, from: 0, spacing: 0, distribution: .evenly, spawn: .forward, accuracy: 100) { index, layout in
            Circle()
              .fill(Color.orange)
              .frame(width: 10, height: 10)
          }
      }
    }
}
```




Draw content along a bezier

```
public extension Shape {
  
  func stroke<NewContent>(itemCount: UInt = 1,
                          from: CGFloat = 0,
                          spacing: CGFloat = 0,
                          distribution: Distribution = .evenly,
                          spawn: Spawn = .forward,
                          accuracy: UInt = 100,
                          @ViewBuilder innerContent: @escaping (UInt, LayoutData) -> NewContent) -> some View where NewContent : View {
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
                                    size: CGSize = CGSize(width: 40, height: 40),
                                    accuracy: UInt = 100,
                                    @ViewBuilder innerContent: @escaping (UInt, LayoutData) -> NewContent) -> some View where NewContent : View {
    modifier(OrnamentStyleWithCanvas(shape: self,
                                     innerContent: innerContent,
                                     itemCount: itemCount,
                                     from: from,
                                     spacing: spacing,
                                     distribution: distribution,
                                     spawn: spawn,
                                     size: size,
                                     accuracy: accuracy))
  }
  
}
```

TODO

- backward has wrong shape on step
