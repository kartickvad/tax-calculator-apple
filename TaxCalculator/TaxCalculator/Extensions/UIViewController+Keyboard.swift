import UIKit

// Fix to a problem where the scrollView did not work after dismissing the keyboard.
extension UIViewController  {

  func keyboardWillShow(_ scrollView: UIScrollView, block: ((CGSize?) -> Void)? = nil ) {
    NotificationCenter
      .default
      .addObserver(forName: UIResponder.keyboardWillShowNotification,
                   object: nil,
                   queue: nil) { notification in
                    defer { block?(CGSize.zero) }

                    guard let userInfo = notification.userInfo else { return }
                    guard let keyboardRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?
                      .cgRectValue else { return }
                    guard let firstResponder = self.view.firstResponder else { return }

                    let keyboardRectNew = self.view.convert(keyboardRect, to: self.view)
                    let scrollViewSpace = scrollView.frame.origin.y + scrollView.contentOffset.y
                    let textFieldRect:CGRect =  firstResponder.convert(firstResponder.bounds, to: self.view)
                    let textFieldSpace = textFieldRect.origin.y + textFieldRect.size.height
                    let remainingSpace = self.view.frame.size.height - keyboardRectNew.size.height
                    let gap = scrollViewSpace + textFieldSpace - remainingSpace

                    if gap > 0 {
                      scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x,
                                                          y: gap),
                                                  animated: true)
                    }
    }
  }

  func keyboardWillHide(_ scrollView:UIScrollView, block: (() -> Void)? = nil) {
    NotificationCenter
      .default
      .addObserver(forName: UIResponder.keyboardWillHideNotification,
                   object: nil,
                   queue: nil,
                   using: { notification in

                    scrollView.scrollRectToVisible(.zero, animated: true)
                    scrollView.contentOffset = .zero
                    scrollView.contentInset = .zero
                    scrollView.scrollIndicatorInsets = .zero

                    block?()
      })
  }
}
