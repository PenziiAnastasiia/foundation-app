//
//  LegalEntityForm.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 04.05.2025.
//

import Foundation
import UIKit

class LegalEntityFormView: UIView, FormView, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    weak var delegate: FormViewDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var organizationNameTextField: UITextField!
    @IBOutlet weak var EDRPOYTextField: UITextField!
    @IBOutlet weak var IBANTextField: UITextField!
    @IBOutlet weak var bankTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var PIBTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    private var changingMode: Bool = false
    
    private let banks = ["ПриватБанк", "Ощадбанк", "UKRSIBBANK", "Альфа-Банк", "ПУМБ", "Універсал банк"]
    private let bankPicker = UIPickerView()
    private var hasAddedUAPrefix = false
    private var hasAddedPhonePrefix = false
    
    private let EDRPOYSize = 8
    private let IBANSize = 29
    private let phoneNumberSize = 13
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.configureBankPicker()
        self.EDRPOYTextField.delegate = self
        self.IBANTextField.delegate = self
        self.phoneNumberTextField.delegate = self
    }
    
    func getScrollView() -> UIScrollView? {
        return self.scrollView
    }
    
    @IBAction func didTappedButton() {
        if !self.getResultOfAllChecks() { return }
        
        guard let user = self.getUser() else { return }
        
        if self.changingMode {
            self.delegate?.didTapSave(user: user)
        } else {
            guard let email = self.emailTextField.text,
                  let password = self.passwordTextField.text else { return }
                  
            self.delegate?.didTapSignUp(email: email, password: password, user: user)
        }
    }
    
    public func configure(changingMode: Bool) {
        [self.organizationNameTextField, self.EDRPOYTextField, self.IBANTextField, self.bankTextField, self.addressTextField, self.PIBTextField, self.phoneNumberTextField, self.emailTextField, self.passwordTextField].forEach { textField in
            textField.applyStandardStyle()
        }
        if changingMode {
            self.configureChangingModeView()
        }
        self.changingMode = changingMode
    }
    
    public func updateErrorLabels(with errorResult: AuthErrorResult) {
        self.emailErrorLabel.text = errorResult.textEmailError
        self.passwordErrorLabel.text = errorResult.textPasswordError
    }
    
    public func resetErrorLabels() {
        self.emailErrorLabel.text = ""
        self.passwordErrorLabel.text = ""
    }
    
    // MARK: - private
    
    @objc private func donePressed() {
        self.bankTextField.resignFirstResponder()
    }
    
    private func configureChangingModeView() {
        guard let user = UserManager.shared.currentUser else { return }
        self.organizationNameTextField.text = user.organizationName
        self.EDRPOYTextField.isUserInteractionEnabled = false
        self.EDRPOYTextField.backgroundColor = .container
        self.EDRPOYTextField.textColor = .gray
        self.EDRPOYTextField.text = user.EDRPOY
        self.IBANTextField.text = user.IBAN
        self.bankTextField.text = user.bank
        self.addressTextField.text = user.address
        self.PIBTextField.text = user.PIB
        self.phoneNumberTextField.text = user.phoneNumber
        self.emailTextField.superview?.isHidden = true
        self.passwordTextField.superview?.isHidden = true
        let attributedTitle = NSAttributedString(
            string: "Зберегти",
            attributes: [
                .font: UIFont.systemFont(ofSize: 20, weight: .regular)
            ]
        )
        self.button.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    private func configureBankPicker() {
        self.bankPicker.delegate = self
        self.bankPicker.dataSource = self
        self.bankTextField.inputView = self.bankPicker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(self.donePressed))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        self.bankTextField.inputAccessoryView = toolbar
    }
    
    // MARK: -- check
    
    private func checkTextFieldHasEnoughText(_ textField: UITextField, neededLength: Int) -> Bool {
        if let length = textField.text?.count, length < neededLength {
            textField.layer.borderColor = UIColor.red.cgColor
            return false
        }
        textField.layer.borderColor = UIColor.gray.cgColor
        return true
    }
    
    private func isValidIBAN() -> Bool {
        guard self.checkTextFieldHasEnoughText(self.IBANTextField, neededLength: self.IBANSize),
              let iban = self.IBANTextField.text
        else { return false }

        print("im here")
        let rearranged = iban.dropFirst(4) + iban.prefix(4)
        var numericIBAN = ""
        for char in rearranged {
            if let digit = char.wholeNumberValue {
                numericIBAN.append(String(digit))
            } else if let ascii = char.asciiValue {
                let value = Int(ascii) - 55
                guard value >= 10 && value <= 35 else { return false }
                numericIBAN.append(String(value))
            } else {
                return false
            }
        }
        print("im here1", numericIBAN)
    
        var remainder = 0
        for char in numericIBAN {
            if let digit = Int(String(char)) {
                remainder = (remainder * 10 + digit) % 97
            } else {
                return false
            }
        }
        print("im here2", remainder)
        
        if !(remainder == 1) {
            self.IBANTextField.layer.borderColor = UIColor.red.cgColor
            return false
        }
        self.IBANTextField.layer.borderColor = UIColor.gray.cgColor
        return true
    }
    
    private func getResultOfAllChecks() -> Bool {
        let checkOrganizationNameResult = self.organizationNameTextField.isNotEmpty
        let checkEDRPOYResult = self.checkTextFieldHasEnoughText(self.EDRPOYTextField, neededLength: self.EDRPOYSize)
        let checkIBANResult = self.isValidIBAN()
        let checkBankResult = self.bankTextField.isNotEmpty
        let checkAddressResult = self.addressTextField.isNotEmpty
        let checkPIBResult = self.PIBTextField.checkPIB()
        let checkPhoneNumberResult = self.checkTextFieldHasEnoughText(self.phoneNumberTextField, neededLength: self.phoneNumberSize)
        
        let isValid =
            checkOrganizationNameResult &&
            checkEDRPOYResult &&
            checkIBANResult &&
            checkBankResult &&
            checkAddressResult &&
            checkPIBResult &&
            checkPhoneNumberResult
        
        if self.changingMode {
            return isValid
        }
        
        let checkEmailResult = self.emailTextField.validateEmail()
        let checkPassword = self.passwordTextField.isNotEmpty
        
        return isValid && checkEmailResult && checkPassword
    }
    
    private func generateEmoji() -> String {
        let emojiArray = ["🏆", "🥇", "🎬", "🎨", "🧩", "🎮", "✈️", "🚁", "🚀",
                          "🛸", "⚓️", "💎", "💵", "💡", "⚖️", "✉️", "🎉"]
        return emojiArray.randomElement() ?? "😎"
    }
    
    private func getUser() -> UserModel? {
        guard let organizationName = self.organizationNameTextField.text,
              let EDRPOY = self.EDRPOYTextField.text,
              let IBAN = self.IBANTextField.text,
              let bank = self.bankTextField.text,
              let address = self.addressTextField.text,
              let pib = self.PIBTextField.text,
              let phoneNumber = self.phoneNumberTextField.text
        else { return nil }
        
        let currentEmoji = UserManager.shared.currentUser?.emoji ?? self.generateEmoji()
        
        return try? UserModel.fromDictionary([
            "PIB": pib,
            "emoji": currentEmoji,
            "type": "legal",
            "organizationName": organizationName,
            "EDRPOY": EDRPOY,
            "IBAN": IBAN,
            "bank": bank,
            "address": address,
            "phoneNumber": phoneNumber
        ])
    }
    
    // MARK: -- addPrefixes
    
    private func addUAPrefix(textField: UITextField) {
        textField.text = "UA"
        self.hasAddedUAPrefix = true
    }
    
    private func addPhonePrefix(textField: UITextField) {
        textField.text = "+380"
        self.hasAddedPhonePrefix = true
    }
    
    // MARK: -- handle
    
    private func handleEDRPOYTextFieldFormatting(newText: String) -> Bool {
        if newText.count > self.EDRPOYSize {
            return false
        }
        return true
    }
    
    private func handleIBANTextFieldFormatting(newText: String, currentText: String) -> Bool {
        if (newText.count < currentText.count && currentText == "UA") || newText.count > self.IBANSize {
            return false
        } else if !newText.contains("UA") {
            self.IBANTextField.text = "UA"
            return false
        }
        return true
    }
    
    private func handlePhoneNumberTextFieldFormatting(newText: String, currentText: String) -> Bool {
        if (newText.count < currentText.count && currentText == "+380") || newText.count > self.phoneNumberSize {
            return false
        } else if !newText.contains("+380") {
            self.phoneNumberTextField.text = "+380"
            return false
        }
        return true
    }
    
    // MARK: - UIPickerViewDelegate, UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.banks.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.banks[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.bankTextField.text = banks[row]
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.IBANTextField && !self.hasAddedUAPrefix && (textField.text?.isEmpty ?? true) {
            self.addUAPrefix(textField: textField)
        } else if textField == self.phoneNumberTextField && !self.hasAddedPhonePrefix && (textField.text?.isEmpty ?? true) {
            self.addPhonePrefix(textField: textField)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        switch textField {
        case self.EDRPOYTextField:
            return self.handleEDRPOYTextFieldFormatting(newText: newText)
        case self.IBANTextField:
            return self.handleIBANTextFieldFormatting(newText: newText, currentText: currentText)
        case self.phoneNumberTextField:
            return self.handlePhoneNumberTextFieldFormatting(newText: newText, currentText: currentText)
        default:
            break
        }
        return true
    }
}
