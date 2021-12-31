//
//  File.swift
//  
//
//  Created by Chris Davis on 30/12/2021.
//

import CoreGraphics

extension CGRect {
  
  /// Creates a CGRect of size: 1x1
  public static var unit: CGRect {
    CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
  }
  
}
