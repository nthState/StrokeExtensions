//
//  SegmentSlicer.swift
//  StrokeExtensions
//
//  Copyright © 2022 Chris Davis, https://www.nthState.com
//
//  See https://github.com/nthState/StrokeExtensions/blob/master/LICENSE for license information.
//
import Foundation
import CoreGraphics

// MARK: Segment Type

internal enum PieceType {
  case unknown
  case space
  case shape
}

internal struct Segment {
  let pieces: [Piece]
}

extension Segment: Equatable {
  
  static func ==(lhs: Segment, rhs: Segment) -> Bool {
    return lhs.pieces == rhs.pieces
  }
  
}

internal struct Piece {
  let start: CGFloat
  let finish: CGFloat
  let type: PieceType
  
  init(_ start: CGFloat, _ finish: CGFloat, _ type: PieceType) {
    self.start = start
    self.finish = finish
    self.type = type
  }
  
  init(_ interval: CGFloat, _ type: PieceType) {
    self.start = interval
    self.finish = interval
    self.type = type
  }
  
  var width: CGFloat {
    finish - start
  }
  
  var isEmptySpace: Bool {
    return start == 0 && finish == 0 && type == .space
  }
}

extension Piece: CustomDebugStringConvertible {
  
  var debugDescription: String {
    "\(start) \(finish) \(type)"
  }
  
}

extension Piece: Equatable {
  
  static func ==(lhs: Piece, rhs: Piece) -> Bool {
    return lhs.start == rhs.start && lhs.finish == rhs.finish && lhs.type == rhs.type
  }
  
}

// MARK: Segment Slicer

internal class SegmentSlicer {
  
  /**
   We can assume sorted data
   */
  class func slice(_ base: [Piece], _ toMerge: [Piece]) -> [Segment] {
    
    func add(piece: Piece) {
      
      if pieces.isEmpty && piece.isEmptySpace {
        return
      }
      
      if pieces.last != piece {
        pieces.append(piece)
      }
    }
    
    let baseLength = base.count
    let toMergeCount = toMerge.count
    
    var mergeCounter: Int = 0
    
    var pieces: [Piece] = []
    var segments: [Segment] = []
    
    // Algorithm goes here
    for i in 0..<baseLength {
      
      let currentMax = base[i].finish
      var currentMin: CGFloat = base[i].start
      
      for j in mergeCounter..<toMergeCount {
        
        if toMerge[j].finish <= currentMax {
          
          add(piece: Piece(currentMin, toMerge[j].start, .space))
          add(piece: toMerge[j])
          
          currentMin = toMerge[j].start
          mergeCounter += 1
        } else {
          
          add(piece: Piece(currentMin, base[i].finish, .space))
          
          break
        }
        
      }
     
      if currentMin < currentMax {
        add(piece: Piece(currentMin, currentMax, .space))
      }
      
      segments.append(Segment(pieces: pieces))
      pieces = []
    }
    
    return segments
  }
  
}
