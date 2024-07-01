import UIKit

extension UISegmentedControl {
  // Segment atamak için

  func replaceSegments(segments: [String]) {
    removeAllSegments()
    for segment in segments {
      insertSegment(withTitle: segment, at: numberOfSegments, animated: false)
    }
  }
}
