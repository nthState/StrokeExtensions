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

internal struct ViewItem: Identifiable {
  let id: Int
  let view: AnyView
  
  public init(id: Int, view: AnyView) {
    self.id = id
    self.view = view
  }
}

public struct OrnamentStyle<S, NewContent>: ViewModifier, ShapeStyle where S: Shape, NewContent: View {
  
  private let path: Path
  private let innerContent: (Int, LayoutData) -> NewContent

  private let traverser: PathTraversal<S>
  
  public init(shape: S,
              @ViewBuilder innerContent: @escaping (Int, LayoutData) -> NewContent,
              itemCount: Int = 1,
              from: CGFloat = 0,
              spacing: CGFloat = 0,
              distribution: Distribution = .evenly,
              direction: Direction = .forward,
              accuracy: UInt = 100) {
    
    self.path = shape.path(in: CGRect.unit)
    self.innerContent = innerContent
    
    self.traverser = PathTraversal(shape: shape,
                                   itemCount: itemCount,
                                   from: from,
                                   spacing: spacing,
                                   distribution: distribution,
                                   direction: direction,
                                   accuracy: accuracy)
  }
  
  public func body(content: Content) -> some View {
    
    let items = buildSubViews(content: content)

    ZStack {
      ForEach(items, id: \.id) { ornamentView in
        ornamentView
          .view
      }

    }
    
  }
  
  private func drawView(content index: Int, at point: CGPoint, angle: Angle, leftNormal: CGPoint) -> some View {
    
    innerContent(index, LayoutData(position: point, angle: angle, leftNormal: leftNormal))
  }
  
  func buildSubViews(content: Content) -> [ViewItem] {
    
    var views: [ViewItem] = []
    
    traverser.traverse(callback: { element, data in
      switch element {
      case .move(to: _):
        break
      case .line(to: _):
        let view = AnyView(drawView(content: data.index, at: data.newPoint, angle: data.angle, leftNormal: data.leftNormal))
        views.append(ViewItem(id: data.index, view: view))
      case .curve(to: _, control1: _, control2: _):
        let view = AnyView(drawView(content: data.index, at: data.newPoint, angle: data.angle, leftNormal: data.leftNormal))
        views.append(ViewItem(id: data.index, view: view))
      case .quadCurve(to: _, control: _):
        let view = AnyView(drawView(content: data.index, at: data.newPoint, angle: data.angle, leftNormal: data.leftNormal))
        views.append(ViewItem(id: data.index, view: view))
      case .closeSubpath:
        let view = AnyView(drawView(content: data.index, at: data.newPoint, angle: data.angle, leftNormal: data.leftNormal))
        views.append(ViewItem(id: data.index, view: view))
      }
    })
    
    return views
  }
  
}
