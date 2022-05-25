import UIKit

/// A scroll view which dimisses the keyboard when the user touches outside the textfield and inside the scrollview.
class DismissableScrollView: UIScrollView {

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    endEditing(false)
  }
}