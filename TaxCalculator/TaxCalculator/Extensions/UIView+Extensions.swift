//
//  UIScrollView+Util.swift
//  TaxCalculator
//
//  Created by Ajo M Varghese on 18/12/19.
//  Copyright © 2019 Helene LLP. All rights reserved.
//

import UIKit

extension UIView {

  var firstResponder -> UIView? {
    if isFirstResponder { return self }
    for subview in subviews {
      let firstResponder = subview.firstResponder
      if nil != firstResponder {
        return firstResponder
      }
    }
    return nil
  }
}
