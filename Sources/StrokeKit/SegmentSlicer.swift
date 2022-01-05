
import Foundation
import CoreGraphics

// MARK: Segment Type

public enum PieceType {
  case unknown
  case space
  case shape
}

public struct Segment {
  let pieces: [Piece]
}

public struct Piece {
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
  
  public var debugDescription: String {
    "\(start) \(finish) \(type)"
  }
  
}

extension Piece: Equatable {
  
  public static func ==(lhs: Piece, rhs: Piece) -> Bool {
    return lhs.start == rhs.start && lhs.finish == rhs.finish && lhs.type == rhs.type
  }
  
}

// MARK: Segment Slicer

class SegmentSlicer {
  
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
