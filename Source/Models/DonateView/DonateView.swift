//
//  DonateView.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 18.04.2025.
//

import UIKit

class DonateView: UIView, UITextFieldDelegate {
    
    @IBOutlet weak var sumDonateTextField: UITextField!
    @IBOutlet weak var sumDonateErrorMessage: UILabel!
    @IBOutlet weak var creditCardNumberTextField: UITextField!
    @IBOutlet weak var creditCardExpiredInTextField: UITextField!
    @IBOutlet weak var creditCardCVV2TextField: UITextField!
    @IBOutlet weak var creditCardErrorMessage: UILabel!
    
    @IBOutlet weak var generateInvoiceButtonContainer: UIView!
    @IBOutlet weak var stackViewContainer: UIView!
    
    private var generateInvoice: ((_ sum: Double) -> Void)?
    private var donate: ((_ sum: Double, _ cardNumber: Int?, _ expiredIn: Date?, _ CVV2: Int?) -> Void)?
    
    private let creditCardNumberTextSize = 4 * 4
    private let creditCardExpiredInSizeWithSlash = 2 * 2 + 1
    private let creditCardCVV2Size = 3
    
    public func configure(generateInvoice: @escaping (_ sum: Double) -> Void) {
        self.sumDonateTextField.applyStandardStyle()
        self.sumDonateTextField.delegate = self
        
        self.generateInvoice = generateInvoice
        
        self.stackViewContainer.isHidden = true
    }

    public func configure(donate: @escaping (Double, Int?, Date?, Int?) -> Void) {
        [self.sumDonateTextField, self.creditCardNumberTextField, self.creditCardExpiredInTextField, self.creditCardCVV2TextField].forEach { textField in
            textField.applyStandardStyle()
        }
        self.sumDonateTextField.delegate = self
        self.creditCardNumberTextField.delegate = self
        self.creditCardExpiredInTextField.delegate = self
        self.creditCardCVV2TextField.delegate = self
        
        self.donate = donate
        
        self.generateInvoiceButtonContainer.isHidden = true
    }
    
    @IBAction func didTappedGenerate() {
        self.sumDonateErrorMessage.text = ""
        
        guard let sum = self.checkDonateSum() else { return }
        
        self.generateInvoice?(sum)
    }
    
    @IBAction func didTappedApplePay() {
        self.sumDonateErrorMessage.text = ""
        
        guard let sum = self.checkDonateSum() else { return }
        
        self.donate?(sum, nil, nil, nil)
    }
    
    @IBAction func didTappedDonate() {
        self.sumDonateErrorMessage.text = ""
        self.creditCardErrorMessage.text = ""
        
        guard let sum = self.checkDonateSum(),
              let cardNumber = self.checkCardNumber(),
              let expiredIn = self.checkCardExpiredIn(),
              let CVV2 = self.checkCardCVV2()
        else { return }
        
        self.donate?(sum, cardNumber, expiredIn, CVV2)
    }
    
    // MARK: - private
    // MARK: -- check
    
    private func checkDonateSum() -> Double? {
        guard let donateSumText = self.sumDonateTextField.text?.replacingOccurrences(of: ",", with: "."),
              let donateSum = Double(donateSumText)
        else {
            self.sumDonateErrorMessage.text = "Введіть суму донату"
            return nil
        }
        
        if donateSum == 0.0 {
            self.sumDonateErrorMessage.text = "Сума донату має бути ненульова"
            return nil
        }
        return donateSum
    }
    
    private func checkCardNumber() -> Int? {
        guard let text = self.creditCardNumberTextField.text,
              let cardNumber = Int(text.replacingOccurrences(of: " ", with: ""))
        else { return nil }
        
        if !self.isValidCardNumber(cardNumber) && cardNumber != 0 {
            self.creditCardErrorMessage.text = "Невірно введено номер картки"
            return nil
        }
        return cardNumber
    }
    
    private func isValidCardNumber(_ cardNumber: Int) -> Bool {  // Luna's algorithm
        let reversedDigits = String(cardNumber).reversed().compactMap { Int(String($0)) }
        var sum = 0
        
        for (index, digit) in reversedDigits.enumerated() {
            if index % 2 == 1 {
                let doubled = digit * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            } else {
                sum += digit
            }
        }
        
        return sum % 10 == 0
    }

    private func checkCardExpiredIn() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yy"
        var expiredInDate: Date

        if let text = self.creditCardExpiredInTextField.text, let date = formatter.date(from: text) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month], from: date)
            let nowComponents = calendar.dateComponents([.year, .month], from: Date())

            if let expYear = components.year, let expMonth = components.month,
               let nowYear = nowComponents.year, let nowMonth = nowComponents.month {
                if expYear < nowYear || (expYear == nowYear && expMonth < nowMonth) { self.creditCardErrorMessage.text = "Карта протермінована"
                    return nil
                }
            }
            expiredInDate = date
        } else {
            self.creditCardErrorMessage.text = "Невірно введено термін дії картки"
            return nil
        }
        return expiredInDate
    }
    
    private func checkCardCVV2() -> Int? {
        if let text = self.creditCardCVV2TextField.text, text.count == self.creditCardCVV2Size, let CVV2 = Int(text) {
            return CVV2
        }
        self.creditCardErrorMessage.text = "Невірно введено CVV2 картки"
        return nil
    }
    
    // MARK: -- handle
    
    private func handleSumDonateFormatting(newText: String) -> Bool {
        if newText.filter({ $0 == "," }).count > 1 {
            return false
        }
        
        if let commaIndex = newText.firstIndex(of: ","), newText[newText.index(after: commaIndex)...].count > 2 {
            return false
        }
        return true
    }
    
    private func handleCardNumberFormatting(newText: String, currentText: String) -> Bool {
        let creditCardNumberTextSizeWithSpaces = self.creditCardNumberTextSize + 3
        
        if newText.count > creditCardNumberTextSizeWithSpaces {
            return false
        }
        
        let rawNewText = newText.replacingOccurrences(of: " ", with: "")
        
        if newText.count > currentText.count && rawNewText.count % 4 == 0 && rawNewText.count < self.creditCardNumberTextSize {
            self.creditCardNumberTextField.text = newText + " "
            return false
        }
        
        if newText.count < currentText.count && currentText.last == " " {
            self.creditCardNumberTextField.text = String(newText.dropLast(1))
            return false
        }
        return true
    }
    
    private func handleCardExpiredInFormatting(newText: String, currentText: String) -> Bool {
        if newText.count > self.creditCardExpiredInSizeWithSlash {
            return false
        }
        
        if newText.count == 2 {
            if newText.count < currentText.count {
                self.creditCardExpiredInTextField.text = String(newText.dropLast(1))
            } else {
                self.creditCardExpiredInTextField.text = newText + "/"
            }
            return false
        }
        return true
    }
    
    private func handleCardCVV2Formatting(newText: String) -> Bool {
        if newText.count > self.creditCardCVV2Size {
            return false
        }
        return true
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        switch textField {
        case self.sumDonateTextField:
            return self.handleSumDonateFormatting(newText: newText)
        case self.creditCardNumberTextField:
            return self.handleCardNumberFormatting(newText: newText, currentText: currentText)
        case self.creditCardExpiredInTextField:
            return self.handleCardExpiredInFormatting(newText: newText, currentText: currentText)
        case self.creditCardCVV2TextField:
            return self.handleCardCVV2Formatting(newText: newText)
        default:
            break
        }
        return true
    }
}
