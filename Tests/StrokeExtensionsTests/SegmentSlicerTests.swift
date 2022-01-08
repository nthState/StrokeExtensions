//
//  SegmentSlicerTests.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/main/LICENSE for license information.
//

import XCTest
@testable import StrokeExtensions

final class SegmentSlicerTests: XCTestCase {

  func testSegmentAndShapesSlice() throws {

    let segments = [Piece(0, 1, .space), Piece(1, 2, .space)]
    let shapes = [Piece(0.4, .shape), Piece(1.4, .shape)]

    let actual: [Segment] = SegmentSlicer.slice(segments, shapes)

    let expected: [Segment] = [Segment(pieces: [Piece(0, 0.4, .space), Piece(0.4, .shape), Piece(0.4, 1, .space)]),
                               Segment(pieces: [Piece(1, 1.4, .space), Piece(1.4, .shape), Piece(1.4, 2, .space)])]

    XCTAssertEqual(actual, expected, "Should match")
  }

  func testSegmentAndShapesSliceAtStart() throws {
    
    let segments = [Piece(0, 1, .space), Piece(1, 2, .space)]
    let shapes = [Piece(0, .shape)]
    
    let actual: [Segment] = SegmentSlicer.slice(segments, shapes)
    
    let expected: [Segment] = [Segment(pieces: [Piece(0, .shape), Piece(0, 1, .space)]),
                               Segment(pieces: [Piece(1, 2, .space)])]
    
    XCTAssertEqual(actual, expected, "Should match")
  }
  
  func testSegmentAndShapesSliceAtEnd() throws {

    let segments = [Piece(0, 1, .space), Piece(1, 2, .space)]
    let shapes = [Piece(1, .shape)]

    let actual: [Segment] = SegmentSlicer.slice(segments, shapes)

    let expected: [Segment] = [Segment(pieces: [Piece(0, 1, .space), Piece(1, .shape)]),
                               Segment(pieces: [Piece(1, 2, .space)])]

    XCTAssertEqual(actual, expected, "Should match")
  }
  
  func testSegmentAndShapesSliceEbd() throws {

    let segments = [Piece(0, 1, .space), Piece(1, 2, .space)]
    let shapes = [Piece(0, .shape), Piece(0.4, .shape), Piece(1.4, .shape)]

    let actual: [Segment] = SegmentSlicer.slice(segments, shapes)

    let expected: [Segment] = [Segment(pieces: [Piece(0, .shape), Piece(0, 0.4, .space), Piece(0.4, .shape), Piece(0.4, 1, .space)]),
                               Segment(pieces: [Piece(1, 1.4, .space), Piece(1.4, .shape),Piece(1.4, 2, .space)])]

    XCTAssertEqual(actual, expected, "Should match")
  }

}
