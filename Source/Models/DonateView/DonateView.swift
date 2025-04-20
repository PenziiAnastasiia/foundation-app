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
    
    class func loadFromNib() -> DonateView? {
        let nib = UINib(nibName: "DonateView", bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil).first as? DonateView
    }
    
    public func configure() {
        self.creditCardNumberTextField.delegate = self
        self.creditCardExpiredInTextField.delegate = self
        self.creditCardCVV2TextField.delegate = self
    }
    
    @IBAction func didTappedApplePay() {
        self.sumDonateErrorMessage.isHidden = false
        self.sumDonateErrorMessage.text = "error"
    }
    
    @IBAction func didTappedDonate() {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        let creditCardNumberTextSize = 4 * 4
        let creditCardNumberTextSizeWithSpaces = creditCardNumberTextSize + 3
        let creditCardExpiredInSizeWithSlash = 2 * 2 + 1
        let creditCardCVV2SizeWithSlash = 3
        
        if textField == self.creditCardNumberTextField {
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
            
        } else if textField == self.creditCardExpiredInTextField {
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
            
        } else if textField == self.creditCardCVV2TextField {
            if newText.count > creditCardCVV2SizeWithSlash {
                return false
            }
        }
        
        return true
    }

}
