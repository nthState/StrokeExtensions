import SwiftUI

// MARK: Shape Ornament Conent

public protocol Ornamentable {
  var id: UUID { get }
  var view: AnyView { get }
}

public struct ShapeOrnament: Identifiable, Ornamentable {
  public let id: UUID
  public let view: AnyView
}

extension View {
  
  public func ornament(_ id: ShapeOrnament.ID) -> ShapeOrnament {
    return ShapeOrnament(id: id,
                        view: AnyView(self))
  }
  
}

@resultBuilder
public struct ShapeContentBuilder {
  
  public static func buildBlock(_ components: ShapeOrnament) -> ShapeOrnament {
    components
  }

  public static func buildEither(first component: ShapeOrnament) -> ShapeOrnament {
    component
  }
  
  public static func buildEither(second component: ShapeOrnament) -> ShapeOrnament {
    component
  }
  
}

public struct LayoutData {
  public let position: CGPoint
  public let angle: Angle
}

// MARK: ZStack

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

// MARK: Canvas

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

public enum Layout {
  case clockwise
  //case anti_clockwise
  //case both
}
