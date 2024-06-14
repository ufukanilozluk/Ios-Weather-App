import UIKit

extension UISegmentedControl {
    // Segment atamak için

    func replaceSegments(segments: Array<String>) {
        removeAllSegments()
        for segment in segments {
            insertSegment(withTitle: segment, at: numberOfSegments, animated: false)
        }
    }
}





