//
//  Double+Extensions.swift
//  TaxCalculator
//
//  Created by Akshit Talwar on 16/12/19.
//  Copyright © 2019 Helene LLP. All rights reserved.
//

import Foundation

extension Double {

  func toCurrency() -> String {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_IN")
    formatter.numberStyle = .decimal

    return "\(formatter.string(from: NSNumber(value: self))!)"
  }
}
