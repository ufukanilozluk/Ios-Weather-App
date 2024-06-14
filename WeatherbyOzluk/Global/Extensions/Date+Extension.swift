import Foundation
extension Date {
    func timeIn24Hour() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

    func dateAndTimeLong() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM EEEE"
        return formatter.string(from: self)
    }
    
    func dayLong() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
}
