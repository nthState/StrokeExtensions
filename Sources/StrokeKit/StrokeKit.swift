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
  public let leftNormal: CGPoint
}

// MARK: Any Container

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

// MARK: Canvas

public extension Shape {
  
  func strokeWithCanvas<NewContent>(itemCount: UInt = 1,
                                    from: CGFloat = 0,
                                    spacing: CGFloat = 0,
                                    distribution: Distribution = .evenly,
                                    spawn: Spawn = .forward,
                                    accuracy: UInt = 100,
                                    @ViewBuilder innerContent: @escaping (UInt, LayoutData) -> NewContent) -> some View where NewContent : View {
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

// MARK: Distribution

public enum Distribution {
  case evenly
  case continuous
}

extension Distribution {
  
  public var description: String {
    switch self {
    case .evenly:
      return "Evenly"
    case .continuous:
      return "From Start"
    }
  }
  
}

// MARK: Spawn

public enum Spawn {
  case forward
  case backward
}

extension Spawn {
  
  public var description: String {
    switch self {
    case .forward:
      return "Forward"
    case .backward:
      return "Backward"
    }
  }
  
}
