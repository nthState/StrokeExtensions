//
//  File.swift
//  
//
//  Created by Chris Davis on 30/12/2021.
//

import SwiftUI
import CoreGraphics
import simd

 struct ViewItem: Identifiable {
  let id: UUID
  let view: AnyView
  
  public init(id: UUID, view: AnyView) {
    self.id = id
    self.view = view
  }
}

public struct OrnamentStyle<S, NewContent>: ViewModifier, ShapeStyle where S: Shape, NewContent: Ornamentable {
  
  private let path: Path
  private let innerContent: (UInt) -> NewContent

  private let traverser: PathTraversal<S, NewContent>
  
  public init(shape: S,
              @ShapeContentBuilder innerContent: @escaping (UInt) -> NewContent,
              itemCount: UInt? = nil,
              from: CGFloat = 0,
              offsetPerItem: [CGPoint] = [],
              spacing: [CGFloat] = [],
              layout: Layout = .clockwise,
              accuracy: UInt = 100) {
    
    self.path = shape.path(in: CGRect.unit)
    self.innerContent = innerContent
    
    self.traverser = PathTraversal(shape: shape,
                                   //innerContent: innerContent,
                                   itemCount: itemCount,
                                   from: from,
                                   offsetPerItem: offsetPerItem,
                                   spacing: spacing,
                                   layout: layout,
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
  
  private func drawView(content index: UInt, at point: CGPoint, angle: Angle) -> some View {
    
    innerContent(index)
      .view
      .id(UUID())
      .rotationEffect(angle)
      .offset(x: point.x/2, y: point.y/2)
      .position(x: point.x/2, y: point.y/2)
    
  }
  
  func buildAubViews(content: Content) -> [ViewItem] {
    
    var views: [ViewItem] = []
    let innerContentWidth: CGFloat = 100
    let size: CGSize = CGSize(width: 100, height: 100)
    
    traverser.traverse(callback: { element, data in
      switch element {
      case .move(to: let point):
        break
      case .line(to: let point):
        let view = AnyView(drawView(content: UInt(data.index), at: data.newPoint, angle: data.angle))
        views.append(ViewItem(id: UUID(), view: view))
      case .curve(to: let point, control1: let control1, control2: let control2):
        let view = AnyView(drawView(content: UInt(data.index), at: data.newPoint, angle: data.angle))
        views.append(ViewItem(id: UUID(), view: view))
      case .quadCurve(to: let point, control: let control):
        break
      case .closeSubpath:
        let view = AnyView(drawView(content: UInt(data.index), at: data.newPoint, angle: data.angle))
        views.append(ViewItem(id: UUID(), view: view))
      }
    })
    
    return views
  }
  
}
