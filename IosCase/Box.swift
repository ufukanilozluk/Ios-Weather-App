
import Foundation

final class Box<T> {
    typealias Listener = (T) -> Void
    var listener: Listener?

    var value: T {
       
        didSet {
            listener?(value)
        }
    }

    init(_ value: T) {
        self.value = value
    }

    func bind(listener: Listener?) {
        self.listener = listener
        
    }
}

//final class ObservableValue<T> {
//  /// Defines the type of the closure that will be used as a listener.
//  typealias ListenerType = (T) -> Void
//
//  /// The current value of the observable.
//  var value: T {
//    didSet {
//      listener?(value)
//    }
//  }
//  private var listener: ListenerType?
//
//  /// Initializes an `ObservableValue` with an initial value.
//  ///
//  /// - Parameter value: The initial value.
//  init(_ value: T) {
//    self.value = value
//  }
//
//  /// Binds a listener to the observable value.
//  ///
//  /// - Parameter listener: The closure to be called whenever the value changes.
//  func bind(listener: ListenerType?) {
//    self.listener = listener
//    listener?(value)
//  }
//
//  ///  Unbinds any previously bound listener.
//  func unbind() {
//    listener = nil
//  }
//
//  deinit {
//    unbind()
//  }
//}
