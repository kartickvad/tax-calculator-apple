import CoreGraphics

extension CGRect {
  var height: CGFloat {
    get {
      return size.height
    }
    set {
      size.height = newValue
    }
  }
}