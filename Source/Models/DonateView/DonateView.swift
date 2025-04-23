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
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var donateButton: UIButton!
    
    class func loadFromNib() -> DonateView? {
        let nib = UINib(nibName: "DonateView", bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil).first as? DonateView
    }
    
    public func configure() {
        [self.sumDonateTextField, self.creditCardNumberTextField, self.creditCardExpiredInTextField, self.creditCardCVV2TextField, self.payButton, self.donateButton].forEach { uiElement in
            uiElement.layer.borderWidth = 0.5
            uiElement.layer.borderColor = UIColor.gray.cgColor
            uiElement.layer.cornerRadius = 8
        }

        self.sumDonateTextField.delegate = self
        self.creditCardNumberTextField.delegate = self
        self.creditCardExpiredInTextField.delegate = self
        self.creditCardCVV2TextField.delegate = self
    }
    
    @IBAction func didTappedApplePay() {
        self.sumDonateErrorMessage.text = ""
        
        if self.checkSumDonate() {
            
        }
    }
    
    @IBAction func didTappedDonate() {
        self.sumDonateErrorMessage.text = ""
        self.creditCardErrorMessage.text = ""
        
        if self.checkSumDonate() && self.checkCardNumber() && self.checkCardExpiredIn() {
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if textField == self.sumDonateTextField {
            return self.handleSumDonateFormatting(newText: newText)
        } else if textField == self.creditCardNumberTextField {
            return self.handleCardNumberFormatting(newText: newText, currentText: currentText, textField: textField)
        } else if textField == self.creditCardExpiredInTextField {
            return self.handleCardExpiredInFormatting(newText: newText, currentText: currentText, textField: textField)
        } else if textField == self.creditCardCVV2TextField {
            return self.handleCardCVV2Formatting(newText: newText)
        }
        return true
    }
    
    private func checkSumDonate() -> Bool {
        guard let sumDonateText = self.sumDonateTextField.text?.replacingOccurrences(of: ",", with: "."),
              let sumDonate = Double(sumDonateText)
        else {
            self.sumDonateErrorMessage.text = "Введіть суму донату"
            return false
        }
        
        if sumDonate == 0.0 {
            self.sumDonateErrorMessage.text = "Сума донату має бути ненульова"
            return false
        }
        return true
    }
    
    private func checkCardNumber() -> Bool {
        guard let cardNumber = self.creditCardNumberTextField.text else { return false }
        let isValid = self.isValidCardNumber(cardNumber)
        
        if !isValid {
            self.creditCardErrorMessage.text = "Невірно введено номер картки"
            return false
        }
        return true
    }
    
    private func isValidCardNumber(_ cardNumber: String) -> Bool {  // Luna's algorithm
        let rawCreditCard = cardNumber.replacingOccurrences(of: " ", with: "")
        guard !rawCreditCard.isEmpty, rawCreditCard.allSatisfy({ $0.isNumber }) else { return false }

        let reversedDigits = rawCreditCard.reversed().map { Int(String($0))! }
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

    
    private func checkCardExpiredIn() -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yy"

        if let text = creditCardExpiredInTextField.text, let date = formatter.date(from: text) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month], from: date)
            let nowComponents = calendar.dateComponents([.year, .month], from: Date())

            if let expYear = components.year, let expMonth = components.month,
               let nowYear = nowComponents.year, let nowMonth = nowComponents.month {
                if expYear < nowYear || (expYear == nowYear && expMonth < nowMonth) { self.creditCardErrorMessage.text = "Карта протермінована"
                    return false
                }
            }
        } else {
            self.creditCardErrorMessage.text = "Невірно введено термін дії картки"
            return false
        }
        return true
    }
    
    private func handleSumDonateFormatting(newText: String) -> Bool {
        if newText.filter({ $0 == "," }).count > 1 {
            return false
        }
        
        if let commaIndex = newText.firstIndex(of: ","), newText[newText.index(after: commaIndex)...].count > 2 {
            return false
        }
        return true
    }
    
    private func handleCardNumberFormatting(newText: String, currentText: String, textField: UITextField) -> Bool {
        let creditCardNumberTextSize = 4 * 4
        let creditCardNumberTextSizeWithSpaces = creditCardNumberTextSize + 3
        
        if newText.count > creditCardNumberTextSizeWithSpaces {
            return false
        }
        
        let rawNewText = newText.replacingOccurrences(of: " ", with: "")
        
        if newText.count > currentText.count && rawNewText.count % 4 == 0 && rawNewText.count < creditCardNumberTextSize {
            textField.text = newText + " "
            return false
        }
        
        if newText.count < currentText.count && currentText.last == " " {
            textField.text = String(newText.dropLast(1))
            return false
        }
        return true
    }
    
    private func handleCardExpiredInFormatting(newText: String, currentText: String, textField: UITextField) -> Bool {
        let creditCardExpiredInSizeWithSlash = 2 * 2 + 1
        
        if newText.count > creditCardExpiredInSizeWithSlash {
            return false
        }
        
        if newText.count == 2 {
            if newText.count < currentText.count {
                textField.text = String(newText.dropLast(1))
            } else {
                textField.text = newText + "/"
            }
            return false
        }
        return true
    }
    
    private func handleCardCVV2Formatting(newText: String) -> Bool {
        let creditCardCVV2SizeWithSlash = 3
        
        if newText.count > creditCardCVV2SizeWithSlash {
            return false
        }
        return true
    }
}
