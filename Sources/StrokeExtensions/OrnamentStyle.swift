//
//  OrnamentStyle.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/master/LICENSE for license information.
//

import SwiftUI
import CoreGraphics
import simd

 struct ViewItem: Identifiable {
  let id: Int
  let view: AnyView
  
  public init(id: Int, view: AnyView) {
    self.id = id
    self.view = view
  }
}

public struct OrnamentStyle<S, NewContent>: ViewModifier, ShapeStyle where S: Shape, NewContent: View {
  
  private let path: Path
  private let innerContent: (UInt, LayoutData) -> NewContent

  private let traverser: PathTraversal<S>
  
  public init(shape: S,
              @ViewBuilder innerContent: @escaping (UInt, LayoutData) -> NewContent,
              itemCount: UInt = 1,
              from: CGFloat = 0,
              spacing: CGFloat = 0,
              distribution: Distribution = .evenly,
              spawn: Spawn = .forward,
              accuracy: UInt = 100) {
    
    self.path = shape.path(in: CGRect.unit)
    self.innerContent = innerContent
    
    self.traverser = PathTraversal(shape: shape,
                                   //innerContent: innerContent,
                                   itemCount: itemCount,
                                   from: from,
                                   spacing: spacing,
                                   distribution: distribution,
                                   spawn: spawn,
                                   accuracy: accuracy)
  }
  
  public func body(content: Content) -> some View {
    
    let items = buildAubViews(content: content)

    ZStack {
      ForEach(items, id: \.id) { ornamentView in
        ornamentView
          .view
      }

    }
    
  }
  
  private func drawView(content index: UInt, at point: CGPoint, angle: Angle, leftNormal: CGPoint) -> some View {
    
    innerContent(index, LayoutData(position: point, angle: angle, leftNormal: leftNormal))
      //.view
    
  }
  
  func buildAubViews(content: Content) -> [ViewItem] {
    
    var views: [ViewItem] = []
    
    traverser.traverse(callback: { element, data in
      switch element {
      case .move(to: let point):
        break
      case .line(to: let point):
        let view = AnyView(drawView(content: UInt(data.index), at: data.newPoint, angle: data.angle, leftNormal: data.leftNormal))
        views.append(ViewItem(id: data.index, view: view))
      case .curve(to: let point, control1: let control1, control2: let control2):
        let view = AnyView(drawView(content: UInt(data.index), at: data.newPoint, angle: data.angle, leftNormal: data.leftNormal))
        views.append(ViewItem(id: data.index, view: view))
      case .quadCurve(to: let point, control: let control):
        break
      case .closeSubpath:
        let view = AnyView(drawView(content: UInt(data.index), at: data.newPoint, angle: data.angle, leftNormal: data.leftNormal))
        views.append(ViewItem(id: data.index, view: view))
      }
    })
    
    return views
  }
  
}
