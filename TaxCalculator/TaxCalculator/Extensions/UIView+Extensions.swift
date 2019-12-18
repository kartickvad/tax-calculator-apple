//
//  UIScrollView+Util.swift
//  TaxCalculator
//
//  Created by Ajo M Varghese on 18/12/19.
//  Copyright © 2019 Helene LLP. All rights reserved.
//

import UIKit

/// To dismiss the keyboard when the user touches outside the textfield and inside the scrollview.
class DismissableScrollView: UIScrollView {

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    endEditing(false)
  }
}

// Fix to a problem where the scrollview did not work after dismissing the keyboard.
extension UIViewController  {

  func keyboardWillShow(_ scrollview: UIScrollView, block: ((CGSize?) -> Void)? = nil ) {
    NotificationCenter
      .default
      .addObserver(forName: UIResponder.keyboardWillShowNotification,
                   object: nil,
                   queue: nil) { (notification) in

                    if let userInfo = notification.userInfo {
                      if let keyboarRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?
                        .cgRectValue {
                        if self.view.findFirstResponder() != nil {
                          let  keyboarRectNew = self.view .convert(keyboarRect, to: self.view)
                          let scrollViewSpace = scrollview.frame.origin.y + scrollview.contentOffset.y
                          let textFieldRect:CGRect =  self.view.findFirstResponder()!
                            .convert(self.view.findFirstResponder()!.bounds, to: self.view)
                          let textFieldSpace = textFieldRect.origin.y + textFieldRect.size.height
                          let remainingSpace =  self.view.frame.size.height - keyboarRectNew.size.height
                          if  scrollViewSpace + textFieldSpace > remainingSpace {
                            let gap = scrollViewSpace + textFieldSpace - remainingSpace
                            scrollview.setContentOffset(CGPoint(x: scrollview.contentOffset.x,
                                                                y: gap),
                                                         animated: true)
                          }
                        }
                      }
                    }
                    block?(CGSize.zero)

    }
  }

  func keyboardWillHide(_ scrollview:UIScrollView, block: (() -> Void)? = nil) {
    NotificationCenter
      .default
      .addObserver(forName: UIResponder.keyboardWillHideNotification,
                   object: nil,
                   queue: nil,
                   using: { (notification) in

                    scrollview.scrollRectToVisible(CGRect(x: 0,
                                                          y: 0,
                                                          width: 0,
                                                          height: 0),
                                                   animated: true)

                    scrollview.contentOffset = CGPoint(x: 0, y: 0)

                    scrollview.contentInset =  UIEdgeInsets(top: 0.0,
                                                            left: 0.0,
                                                            bottom: 0.0,
                                                            right: 0.0)

                    scrollview.scrollIndicatorInsets = UIEdgeInsets(top: 0.0,
                                                                    left: 0.0,
                                                                    bottom: 0.0,
                                                                    right: 0.0)

                    block?()
      })
  }

  // As of iOS 9, we don't need to remove observers ourselves, but since we're using
  // block based observers we have to remove them manually
  func removeKeyboardObservers() {
    NotificationCenter.default.removeObserver(self,
                                              name: UIResponder.keyboardWillShowNotification,
                                              object: nil)
    NotificationCenter.default.removeObserver(self,
                                              name: UIResponder.keyboardWillHideNotification,
                                              object: nil)

    self.view.findFirstResponder()?.resignFirstResponder()
  }
}

extension UIView {

  func findFirstResponder() -> UIView? {
    if self.isFirstResponder { return self }
    for subview: UIView in self.subviews {
      let firstResponder = subview.findFirstResponder()
      if nil != firstResponder {
        return firstResponder
      }
    }
    return nil
  }
}
