# StrokeKit

Adorn your SwiftUI Shapes/Beziers with Ornaments


Draw content along a bezier

```
stroke<NewContent>(itemCount: UInt? = nil,
                          direction: Direction = .rightToLeft,
                          spacing: [CGFloat] = [],
                          accuracy: UInt = 100,
                          @ViewBuilder innerContent: @escaping () -> NewContent)
```

Draw content along a bezier using a `Canvas` as the backing buffer

```
strokeWithCanvas<NewContent>(itemCount: UInt? = nil,
                          direction: Direction = .rightToLeft,
                          spacing: [CGFloat] = [],
                          accuracy: UInt = 100,
                          @ViewBuilder innerContent: @escaping () -> NewContent)
```

Useful for debugging shapes, or just calling our the joints on a `shape`

```
strokeAtJoins<NewContent>(itemCount: UInt? = nil,
                          direction: Direction = .rightToLeft,
                          spacing: [CGFloat] = [],
                          accuracy: UInt = 100,
                          @ViewBuilder innerContent: @escaping () -> NewContent)

```

we could have  a path iterator that returns a closure to draw the view item
