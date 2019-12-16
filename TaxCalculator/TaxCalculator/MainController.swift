//
//  MainController.swift
//  TaxCalculator
//
//  Created by Akshit Talwar on 16/12/19.
//  Copyright © 2019 Helene LLP. All rights reserved.
//

import UIKit

class MainController: UIViewController, UITextFieldDelegate {

  var PF_RATE: Double = 0.0
  var PROFESSIONAL_TAX: Double = 2500
  var PRESUMPTIVE_RATE: Double = 0.5
  var EMPLOYEE_TAX_DEDUCTION: Double = 16000
  var GST_RATE: Double = 0
  var SLAB_1: Double = 250000
  var SLAB_2: Double =  500000
  var SLAB_3: Double = 1000000




  // MARK:- Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    print(calcCtcForTakeHome(50000))
    print(calcTakeHomeFor(1000000))
  }

  // Called when the user clicks on the view outside the UITextField.
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }




  // MARK:- Outlets

  @IBOutlet private weak var takeHomePayTextfield: UITextField!
  @IBOutlet private weak var ctcForEmployeeTextField: UITextField!
  @IBOutlet weak var ctcForEmployeeLabel: UILabel!
  @IBOutlet private weak var professionalTaxTextfield: UITextField!
  @IBOutlet private weak var pfRateTextField: UITextField!
  @IBOutlet private weak var presumtiveTaxationRateTextField: UITextField!
  @IBOutlet private weak var gstRateTextField: UITextField!
  @IBOutlet private weak var isEmployeeSegmentedControl: UISegmentedControl!




  // MARK:- IBActions

  @IBAction private func takeHomePayChanged(_ sender: UITextField) {

    guard var takeHomePay = Double(sender.text!) else {
      ctcForEmployeeTextField.text = "0.0"
      return
    }
    isTakeHomeEntered = true

    ctcForEmployeeTextField.text = calcCtcForTakeHome(takeHomePay).toCurrency()
  }

  @IBAction private func ctcForEmployeeChanged(_ sender: UITextField) {
    guard var ctc = Double(sender.text!) else {
      takeHomePayTextfield.text = "0"
      return
    }
    isTakeHomeEntered = false
    takeHomePayTextfield.text = calcTakeHomeFor(ctc).toCurrency()
  }

  @IBAction private func professionalTaxValueChanged(_ sender: UITextField) {
    // TODO: Calculate
  }

  @IBAction private func pfRateChanged(_ sender: UITextField) {
    // TODO: Calculate
  }

  @IBAction private func presumtiveTaxationRateChanged(_ sender: UITextField) {
    // TODO: Calculate
  }

  @IBAction private func gstRateChanged(_ sender: UITextField) {
    // TODO: Calculate
  }

  @IBAction func employeeOrConsultantSegmentChanged(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      ctcForEmployeeLabel.text = "CTC for employee"
    case 1:
      ctcForEmployeeLabel.text = "Gross income for consultant"
    default:
      break
    }
    
    if isTakeHomeEntered {
      takeHomePayChanged(takeHomePayTextfield)
    } else {
      ctcForEmployeeChanged(ctcForEmployeeTextField)
    }
  }



  // MARK:- Private

  private var isTakeHomeEntered = false


  private var isEmployee: Bool {
    return isEmployeeSegmentedControl.selectedSegmentIndex == 0
  }

//  private func lac(_ amount: Double) -> Double {
//    return amount * 100
//  }

  private func incomeTaxSlab1(_ income: Double) -> Double {
    var calculatedIncome = income
    if income <= SLAB_1 {
      return 0
    }
    if income > SLAB_2 {
      calculatedIncome = SLAB_2
    }
    calculatedIncome -= SLAB_1

    return calculatedIncome * 0.05 // 5% tax rate for this slab
  }

  private func incomeTaxSlab2(_ income: Double) -> Double {
    var calculatedIncome = income
    if income <= SLAB_2 {
      return 0
    }
    if income > SLAB_3 {
      calculatedIncome = SLAB_3
    }
    calculatedIncome -= SLAB_2

    return calculatedIncome * 0.2 // 20% tax rate for this slab
  }

  private func incomeTaxSlab3(_ income: Double) -> Double {
    var calculatedIncome = income
    if income <= SLAB_3 {
      return 0
    }
    calculatedIncome -= SLAB_3

    return calculatedIncome * 0.3 // 30% tax rate for this slab
  }

  private func incomeTaxFor(_ income: Double) -> Double {
    if income <= 500000 { // 5L
      return 0.0
    }

    let tax = incomeTaxSlab1(income) + incomeTaxSlab2(income) + incomeTaxSlab3(income)
    let cess = tax * 0.04 // Health and education cess is 4% of the tax
    var surcharge: Double = 0.0
    if income >=  10000000 { // 100L
      print("Warning: ignoring surcharge for high income")
    }
    if income >=  5000000 { // 50L
      surcharge = tax * 0.1
    }
    return tax + cess + surcharge
  }

  private func incomeAndProfessionalTaxFor(_ income: Double) -> Double {
    return incomeTaxFor(income) + PROFESSIONAL_TAX
  }

  private func totalTaxFor(_ income: Double, isEmployee: Bool) -> Double {
    if isEmployee {
      return incomeAndProfessionalTaxFor(income - EMPLOYEE_TAX_DEDUCTION)
    }

    let effectiveGSTRate = GST_RATE / (1 + GST_RATE)

    let gst = income * effectiveGSTRate

    let calculatedIncome = income * PRESUMPTIVE_RATE

    return incomeAndProfessionalTaxFor(calculatedIncome) + gst

  }

  private func pfFor(_ income: Double) -> Double {
    // To calculate PF, your salary is capped at 15k
    return min(income, 15000) * PF_RATE
  }

  private func takeHome(_ income: Double, isEmployee: Bool) -> Double {
    let tax = totalTaxFor(income, isEmployee: isEmployee)
    let pf = isEmployee ? pfFor(income) : 0.0
    let calculatedIncome = income - tax - pf

    // round to the nearest thousand
    return floor(calculatedIncome / 12)
  }

  private func calcTakeHomeFor(_ income: Double) -> Double {
    return takeHome(income, isEmployee: isEmployee)
  }

  private func ctcForTakeHomePay(_ desiredTakeHome: Double, isEmployee: Bool) -> Double {
    var ctc: Double = 1.0
    while takeHome(ctc, isEmployee: isEmployee) < desiredTakeHome {
      ctc += 1
    }
    return ctc
  }

  private func calcCtcForTakeHome(_ desiredTakeHome: Double) -> Double {
    return ctcForTakeHomePay(desiredTakeHome, isEmployee: isEmployee)
  }

}

