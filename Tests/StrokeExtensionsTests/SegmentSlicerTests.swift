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

    let segments = [Segment(pieces: [], length: 1), Segment(pieces: [], length: 1)]
    let shapes = [Piece(0.4, .shape), Piece(1.4, .shape)]

    let actual: [Segment] = SegmentSlicer.slice(segments, shapes)

    let expected: [Segment] = [Segment(pieces: [Piece(0.4, .shape)], length: 1),
                               Segment(pieces: [Piece(0.3999999999999999, .shape)], length: 1)]

    XCTAssertEqual(actual, expected, "Should match")
  }

  func testSegmentAndShapesSliceAtStart() throws {
    
    let segments = [Segment(pieces: [], length: 1), Segment(pieces: [], length: 1)]
    let shapes = [Piece(0, .shape)]
    
    let actual: [Segment] = SegmentSlicer.slice(segments, shapes)
    
    let expected: [Segment] = [Segment(pieces: [Piece(0, .shape)], length: 1),
                               Segment(pieces: [], length: 1)]
    
    XCTAssertEqual(actual, expected, "Should match")
  }
  
  func testSegmentAndShapesSliceAtEnd() throws {

    let segments = [Segment(pieces: [], length: 1), Segment(pieces: [], length: 1)]
    let shapes = [Piece(1, .shape)]

    let actual: [Segment] = SegmentSlicer.slice(segments, shapes)

    let expected: [Segment] = [Segment(pieces: [Piece(1, .shape)], length: 1),
                               Segment(pieces: [], length: 1)]

    XCTAssertEqual(actual, expected, "Should match")
  }
  
  func testSegmentAndShapesSliceEbd() throws {

    let segments = [Segment(pieces: [], length: 1), Segment(pieces: [], length: 1)]
    let shapes = [Piece(0, .shape), Piece(0.4, .shape), Piece(1.4, .shape)]

    let actual: [Segment] = SegmentSlicer.slice(segments, shapes)

    let expected: [Segment] = [Segment(pieces: [Piece(0, .shape), Piece(0.4, .shape)], length: 1),
                               Segment(pieces: [Piece(0.3999999999999999, .shape)], length: 2)]

    XCTAssertEqual(actual, expected, "Should match")
  }

}
