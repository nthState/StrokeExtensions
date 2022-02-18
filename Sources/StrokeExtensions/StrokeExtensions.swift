//
//  StrokeExtensions.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/main/LICENSE for license information.
//

import SwiftUI

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
  
  /**
   Stroke the path with Views
   
   - Parameter itemCount: How many items you want along the path
   - Parameter from: Percentage along the shape where the first item spawns
   - Parameter spacing: Amount of space between each item
   - Parameter distribution: Are the items spaced using the spacing, or spread out evenly?
   - Parameter direction: Place items forward or backward on the path
   - Parameter accuracy: Used for calculating ArcLengths, bump up only if required
   - Parameter innerContent: The content to be used for each item
   
   - Returns: View
   */
  func stroke<NewContent>(itemCount: Int = 1,
                          from: CGFloat = 0,
                          spacing: CGFloat = 0,
                          distribution: Distribution = .evenly,
                          direction: Direction = .forward,
                          accuracy: UInt = 100,
                          @ViewBuilder innerContent: @escaping (Int, LayoutData) -> NewContent) -> some View where NewContent : View {
    modifier(OrnamentStyle(shape: self,
                           innerContent: innerContent,
                           itemCount: itemCount,
                           from: from,
                           spacing: spacing,
                           distribution: distribution,
                           direction: direction,
                           accuracy: accuracy))
  }
  
}

// MARK: Canvas

public extension Shape {
  
  func strokeWithCanvas<NewContent>(itemCount: Int = 1,
                                    from: CGFloat = 0,
                                    spacing: CGFloat = 0,
                                    distribution: Distribution = .evenly,
                                    direction: Direction = .forward,
                                    size: CGSize = CGSize(width: 40, height: 40),
                                    accuracy: UInt = 100,
                                    @ViewBuilder innerContent: @escaping (Int, LayoutData) -> NewContent) -> some View where NewContent : View {
    modifier(OrnamentStyleWithCanvas(shape: self,
                                     innerContent: innerContent,
                                     itemCount: itemCount,
                                     from: from,
                                     spacing: spacing,
                                     distribution: distribution,
                                     direction: direction,
                                     size: size,
                                     accuracy: accuracy))
  }
  
}

// MARK: Distribution

/**
 Where View's are spaced on the path
 
 If you pick evenly, then Views are spaced based on pathLength/itemCount
 
 If you pick continuous, Views are spaced via the `spacing`
 */
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
      return "Continuous"
    }
  }
  
}

// MARK: Spawn

/**
 The direction in which views are created on the path
 */
public enum Direction {
  case forward
  case backward
}

public extension Direction {
  
  var description: String {
    switch self {
    case .forward:
      return "Going Forward"
    case .backward:
      return "Going Backward"
    }
  }
  
}
