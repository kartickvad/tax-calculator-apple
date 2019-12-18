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
