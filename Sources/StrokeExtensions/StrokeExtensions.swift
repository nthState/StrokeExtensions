//
//  StrokeExtensions.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/master/LICENSE for license information.
//

import SwiftUI

//// MARK: Shape Ornament Conent
//
//public protocol Ornamentable {
//  var id: UUID { get }
//  var view: AnyView { get }
//}
//
//public struct ShapeOrnament: Identifiable, Ornamentable {
//  public let id: UUID
//  public let view: AnyView
//}
//
//extension View {
//
//  public func ornament(_ id: ShapeOrnament.ID) -> ShapeOrnament {
//    return ShapeOrnament(id: id,
//                        view: AnyView(self))
//  }
//
//}
//
//@resultBuilder
//public struct ShapeContentBuilder {
//
//  public static func buildBlock(_ components: ShapeOrnament) -> ShapeOrnament {
//    components
//  }
//
//  public static func buildEither(first component: ShapeOrnament) -> ShapeOrnament {
//    component
//  }
//
//  public static func buildEither(second component: ShapeOrnament) -> ShapeOrnament {
//    component
//  }
//
//}

/// Provided for each point on the path
public struct LayoutData {
  /// Position along the path
  public let position: CGPoint
  /// Rotation angle based on previous point
  public let angle: Angle
  /// Normal to the point on the line, useful for knowing if the line is pointing inwards or outwards
  public let leftNormal: CGPoint
}

// MARK: Any Container

public extension Shape {
  
  func stroke<NewContent>(itemCount: Int = 1,
                          from: CGFloat = 0,
                          spacing: CGFloat = 0,
                          distribution: Distribution = .evenly,
                          spawn: Spawn = .forward,
                          accuracy: UInt = 100,
                          @ViewBuilder innerContent: @escaping (Int, LayoutData) -> NewContent) -> some View where NewContent : View {
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
  
  func strokeWithCanvas<NewContent>(itemCount: Int = 1,
                                    from: CGFloat = 0,
                                    spacing: CGFloat = 0,
                                    distribution: Distribution = .evenly,
                                    spawn: Spawn = .forward,
                                    size: CGSize = CGSize(width: 40, height: 40),
                                    accuracy: UInt = 100,
                                    @ViewBuilder innerContent: @escaping (Int, LayoutData) -> NewContent) -> some View where NewContent : View {
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

// MARK: Distribution

public enum Distribution {
  case evenly
  case continuous
}

public extension Distribution {
  
  var description: String {
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

public extension Spawn {
  
  var description: String {
    switch self {
    case .forward:
      return "Forward"
    case .backward:
      return "Backward"
    }
  }
  
}
