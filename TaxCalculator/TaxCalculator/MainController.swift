//
//  MainController.swift
//  TaxCalculator
//
//  Created by Akshit Talwar on 16/12/19.
//  Copyright © 2019 Helene LLP. All rights reserved.
//

import UIKit

class MainController: UIViewController, UITextFieldDelegate {





  // MARK:- Lifecycle

  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return UIDevice.current.userInterfaceIdiom == .phone
      ? .portrait  // Our UI breaks on iPhone in landscape mode.
      : .all  // Permit all four orientations on iPad, since mine are always in landscape.
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    if #available(iOS 13.0, *) {
      overrideUserInterfaceStyle = .light
    }

    updatePfRate()
    updatePresumptiveRate()
    updateGstRate()

    // Enable the scroll only on phones whose screensize is less than iPhone X.
    if screenHeight < CGFloat(iPhoneXScreenHeight) {
      optionsScrollView.isScrollEnabled = true
      optionsScrollView.bounces = true
      optionsScrollView.showsVerticalScrollIndicator = true
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    registerForKeyboardNotifications(optionsScrollView)
  }

  // Called when the user clicks on the view outside the UITextField.
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    activeField?.resignFirstResponder()
    return true
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }

  func textFieldDidBeginEditing(_ textField: UITextField) {
    activeField = textField
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    activeField = nil
  }




  // MARK:- Outlets

  @IBOutlet private weak var takeHomePayTextfield: UITextField!
  @IBOutlet private weak var ctcForEmployeeTextField: UITextField!
  @IBOutlet private weak var ctcForEmployeeLabel: UILabel!
  @IBOutlet private weak var pfRateLabel: UILabel!
  @IBOutlet private weak var presumptiveRateLabel: UILabel!
  @IBOutlet private weak var gstRateLabel: UILabel!
  @IBOutlet private weak var isEmployeeSegmentedControl: UISegmentedControl!
  @IBOutlet private weak var taxSavingInvestmentLabel: UILabel!
  @IBOutlet private weak var optionsScrollView: UIScrollView!

  @IBOutlet private weak var professionalTaxTextfield: UITextField! {
    didSet {
      professionalTaxTextfield.text = String(UInt(PROFESSIONAL_TAX))
    }
  }

  @IBOutlet private weak var pfRateTextField: UITextField! {
    didSet {
      pfRateTextField.text = String(UInt(PF_RATE*100))
    }
  }

  @IBOutlet private weak var presumtiveTaxationRateTextField: UITextField! {
    didSet {
      // The UInt() causes it to show as 50 rather than 50.0:
      presumtiveTaxationRateTextField.text = String(UInt(PRESUMPTIVE_RATE*100))
    }
  }

  @IBOutlet private weak var gstRateTextField: UITextField! {
    didSet {
      gstRateTextField.text = String(UInt(GST_RATE*100))
    }
  }

  @IBOutlet weak var taxSavinInvestmentTextField: UITextField! {
    didSet {
      taxSavinInvestmentTextField.text = String(UInt(EMPLOYEE_TAX_DEDUCTION))
    }
  }

  @IBOutlet weak var basicSalaryPercentageTextField: UITextField! {
    didSet {
      basicSalaryPercentageTextField.text = String(UInt(BASIC_RATE*100))
    }
  }

  


  // MARK:- IBActions

  @IBAction private func takeHomePayChanged(_ sender: UITextField) {
    guard let takeHomePay = Double(sender.text!.replacingOccurrences(of: ",", with: "")) else {
      ctcForEmployeeTextField.text = ""
      return
    }
    isTakeHomeEnteredLast = true

    ctcForEmployeeTextField.text = calcCtcForTakeHome(takeHomePay).toCurrency()
  }

  @IBAction private func ctcForEmployeeChanged(_ sender: UITextField) {
    guard let ctc = Double(sender.text!.replacingOccurrences(of: ",", with: "")) else {
      takeHomePayTextfield.text = ""
      return
    }
    isTakeHomeEnteredLast = false
    takeHomePayTextfield.text = calcTakeHomeFor(ctc).toCurrency()
  }

  @IBAction private func professionalTaxValueChanged(_ sender: UITextField) {
    PROFESSIONAL_TAX = Double(sender.text!.replacingOccurrences(of: ",", with: "")) ?? 0.0
    updateTakeHomeOrCtc()
  }

  @IBAction private func pfRateChanged(_ sender: UITextField) {
    PF_RATE = (Double(sender.text!) ?? 0.0)/100
    updateTakeHomeOrCtc()
  }

  @IBAction private func presumtiveTaxationRateChanged(_ sender: UITextField) {
    PRESUMPTIVE_RATE = (Double(sender.text!) ?? 0.0)/100
    updateTakeHomeOrCtc()
  }

  @IBAction private func gstRateChanged(_ sender: UITextField) {
    GST_RATE = (Double(sender.text!) ?? 0.0)/100
    updateTakeHomeOrCtc()
  }

  @IBAction func basicSalaryPercentageChanged(_ sender: UITextField) {
    BASIC_RATE = (Double(sender.text!)) ?? 0.0/100
    updateTakeHomeOrCtc()
  }

  @IBAction private func employeeOrConsultantSegmentChanged(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      ctcForEmployeeLabel.text = "CTC for employee"
    case 1:
      ctcForEmployeeLabel.text = "Gross income for freelancer"
    default:
      fatalError("Unexpected segmented control selection")
      break
    }

    updatePfRate()
    updatePresumptiveRate()
    updateGstRate()
    updateTakeHomeOrCtc()
    updateTaxSavingInvestments()
  }

  @IBAction func taxSavinInvestmentChanged(_ sender: UITextField) {
    EMPLOYEE_TAX_DEDUCTION = Double(sender.text!) ?? 0.0
    updateTakeHomeOrCtc()
  }




  // MARK:- Private

  private var isTakeHomeEnteredLast = false
  private var activeField: UITextField?

  private var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
  }

  @objc private func keyboardWillShow(notification: NSNotification) {
    let userInfo = notification.userInfo!
    optionsScrollView.isScrollEnabled = true
    let keyboardSize = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
    let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height + 50, right: 0.0)

    optionsScrollView.contentInset = contentInsets
    optionsScrollView.scrollIndicatorInsets = contentInsets

    var aRect : CGRect = view.frame
    aRect.height -= keyboardSize!.height
    if activeField != nil {
      if (!aRect.contains(activeField!.frame.origin)) {
        optionsScrollView.scrollRectToVisible(activeField!.frame, animated: true)
      }
    }
  }


  @objc private func keyboardWillHide(notification: NSNotification) {
    let userInfo = notification.userInfo!
    let keyboardSize = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
    let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
    optionsScrollView.contentInset = contentInsets
    optionsScrollView.scrollIndicatorInsets = contentInsets
    view.endEditing(true)
    optionsScrollView.isScrollEnabled = false
  }

  private func updateTakeHomeOrCtc() {
    if isTakeHomeEnteredLast {
      takeHomePayChanged(takeHomePayTextfield)
    } else {
      ctcForEmployeeChanged(ctcForEmployeeTextField)
    }
  }

  private func updatePfRate() {
    if isEmployee {
      pfRateLabel.textColor = .darkText
      pfRateTextField.isEnabled = true
    } else {
      pfRateLabel.textColor = .lightGray
      pfRateTextField.isEnabled = false
    }
  }

  private func updatePresumptiveRate() {
    if isEmployee {
      presumptiveRateLabel.textColor = .lightGray
      presumtiveTaxationRateTextField.isEnabled = false
    } else {
      presumptiveRateLabel.textColor = .darkText
      presumtiveTaxationRateTextField.isEnabled = true
    }
  }

  private func updateGstRate() {
    if isEmployee {
      gstRateLabel.textColor = .lightGray
      gstRateTextField.isEnabled = false
    } else {
      gstRateLabel.textColor = .darkText
      gstRateTextField.isEnabled = true
    }
  }

  private func updateTaxSavingInvestments() {
    if isEmployee {
      taxSavingInvestmentLabel.textColor = .darkText
      taxSavinInvestmentTextField.isEnabled = true
    } else {
      taxSavingInvestmentLabel.textColor = .lightGray
      taxSavinInvestmentTextField.isEnabled = false
    }
  }

  private var isEmployee: Bool {
    return isEmployeeSegmentedControl.selectedSegmentIndex == 0
  }

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
    var surcharge: Double = 0.0
    if income >=  10000000 { print("Warning: ignoring surcharge for high income") } // 100L
    if income >=  5000000 { surcharge = tax * 0.1 } // 50L
    let cess = (tax + surcharge) * 0.04 // Health and education cess is 4% of the tax
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
    return min(income, 15000) * BASIC_RATE * PF_RATE
  }

  private func takeHome(_ income: Double, isEmployee: Bool) -> Double {
    let tax = totalTaxFor(income, isEmployee: isEmployee)
    let pf = isEmployee ? pfFor(income) : 0.0
    let calculatedIncome = income - tax - pf

    // Round to the nearest rupee:
    return floor(calculatedIncome / 12)
  }

  private func calcTakeHomeFor(_ income: Double) -> Double {
    return takeHome(income, isEmployee: isEmployee)
  }

  private func ctcForTakeHomePay(_ desiredTakeHome: Double, isEmployee: Bool) -> Double {
    var ctc: Double = 1.0
    while takeHome(ctc, isEmployee: isEmployee) < desiredTakeHome {
      // If the required CTC is very high, this loop takes a long time, making the app unresponsive.
      // Fix that by increasing CTC by a thousand rupees each time, or by 1%, whichever is higher.
      //
      // The 1% is required for giant numbers, because otherwise it will be linear time -- if the
      // user appends a zero, making the number ten times bigger, it will take ten times longer.
      ctc = max(ctc + 1000, ctc * 1.01)
    }
    return ctc
  }

  private func calcCtcForTakeHome(_ desiredTakeHome: Double) -> Double {
    return ctcForTakeHomePay(desiredTakeHome, isEmployee: isEmployee)
  }
}
 
/// Assuming we're not subject to PF.
fileprivate let PF_RATE: Double = 0.0

/// 40% of salary is considered basic.
fileprivate let BASIC_RATE: Double = 0.4

/// For Karnataka.
fileprivate let PROFESSIONAL_TAX: Double = 2500

/// Assuming you're availaing of presumptive taxation under section 44AD(A).
fileprivate let PRESUMPTIVE_RATE: Double = 0.5

/// Employees (not consultants) are eligible for this.
fileprivate let EMPLOYEE_TAX_DEDUCTION: Double = 160000 

/// Assuming GST is not applicable.
fileprivate let GST_RATE: Double = 0

fileprivate let SLAB_1: Double = 250_000
fileprivate let SLAB_2: Double = 500_000
fileprivate let SLAB_3: Double = 1000_000

/// TODO: Instead calculate the height of the UI and compare it to the screen height to enable
/// scrolling.
fileprivate let iPhoneXScreenHeight = 812