//
//  CircleTests.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/main/LICENSE for license information.
//

import XCTest
import SwiftUI
@testable import StrokeExtensions

class CircleTests: XCTestCase {
  
  /**
   A circle of diameter 1, has a circumference of 3.14, however,  when using sections we'd expect to see
   
    1 item = 0
    2 item = 0.77
    3 item = 1.54
    4 item = 2.31
   
   This means, the last item of 2.31 won't fall into the fourth set 3-4
   */
  func test_length_smaller_sizes() throws {

    let segments = [Segment(pieces: [], length: 1),
                    Segment(pieces: [], length: 1),
                    Segment(pieces: [], length: 1),
                    Segment(pieces: [], length: 1)]
    let shapes = [Piece(0, .shape), Piece(0.77, .shape), Piece(1.54, .shape), Piece(2.31, .shape)]

    let actual: [Segment] = SegmentSlicer.slice(segments, shapes)

    let expected: [Segment] = [Segment(pieces: [Piece(0, .shape), Piece(0.77, .shape)], length: 1),
                               Segment(pieces: [Piece(0.54, .shape)], length: 2),
                               Segment(pieces: [Piece(0.31000000000000005, .shape)], length: 3),
                               Segment(pieces: [], length: 4)]

    XCTAssertEqual(actual, expected, "Should match")
  }
  
}
