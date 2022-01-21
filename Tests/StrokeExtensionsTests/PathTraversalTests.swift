//
//  SegmentSlicerTests.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/main/LICENSE for license information.
//

import XCTest
import SwiftUI
@testable import StrokeExtensions

class PathTraversalTests: XCTestCase {
  
  func test_traverse_called() throws {
    
    let expectation = XCTestExpectation(description: "")
        
    
    let shape = Rectangle()
    
    let p = PathTraversal(shape: shape)
    
    p.traverse { element, item in
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 1)
  }
  
}
