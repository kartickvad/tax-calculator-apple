import UIKit

extension UITextField {

  /// The number entered in the text field, or nul if it's not a number.
  var number: Double? {
     return Double(text!.replacingOccurrences(of: ",", with: ""))
  }
}