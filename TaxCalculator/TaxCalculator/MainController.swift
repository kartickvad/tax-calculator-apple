//
//  MainController.swift
//  TaxCalculator
//
//  Created by Akshit Talwar on 16/12/19.
//  Copyright © 2019 Helene LLP. All rights reserved.
//

import UIKit

class MainController: UIViewController {

  // MARK:- Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

  }




  // MARK:- Outlets


  @IBOutlet weak var takeHomePayTextfield: UITextField!
  @IBOutlet weak var ctcForEmployeeTextField: UITextField!
  @IBOutlet weak var professionalTaxTextfield: UITextField!
  @IBOutlet weak var pfRateTextField: UITextField!
  @IBOutlet weak var presumtiveTaxationRateTextField: UITextField!
  @IBOutlet weak var gstRateTextField: UITextField!




  // MARK:- IBActions

  @IBAction func takeHomePayChanged(_ sender: UITextField) {
    let userEnterdText = Int(takeHomePayTextfield.text!)
    // TODO: Calculate
  }

  @IBAction func ctcForEmployeeChanged(_ sender: UITextField) {
    // TODO: Calculate
  }

  @IBAction func professionalTaxValueChanged(_ sender: UITextField) {
    // TODO: Calculate
  }

  @IBAction func pfRateChanged(_ sender: UITextField) {
    // TODO: Calculate
  }

  @IBAction func presumtiveTaxationRateChanged(_ sender: UITextField) {
    // TODO: Calculate
  }

  @IBAction func gstRateChanged(_ sender: UITextField) {
    // TODO: Calculate
  }
}

