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
    
    @IBOutlet weak var applePayButtonContainer: UIView!
    @IBOutlet weak var generateInvoiceButtonContainer: UIView!
    
    private var generateInvoice: ((_ sum: Double) -> Void)?

    public func configure(with applePayButton: UIButton? = nil, generateInvoice: ((Double) -> Void)? = nil) {
        self.sumDonateTextField.applyStandardStyle()
        self.sumDonateTextField.delegate = self
        
        if let generateInvoice = generateInvoice {
            self.applePayButtonContainer.isHidden = true
            self.generateInvoiceButtonContainer.isHidden = false
            self.generateInvoice = generateInvoice
        } else if let button = applePayButton {
            self.generateInvoiceButtonContainer.isHidden = true
            self.applePayButtonContainer.isHidden = false
            button.embedIn(self.applePayButtonContainer, constant: 16.0)
        }
    }
    
    public func getDonationSum() -> Double? {
        self.sumDonateErrorMessage.text = ""
        return self.checkDonateSum()
    }
    
    @IBAction func didTappedGenerate() {
        self.sumDonateErrorMessage.text = ""
        
        guard let sum = self.checkDonateSum() else { return }
        
        self.generateInvoice?(sum)
    }
    
    // MARK: - private
    
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
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if newText.filter({ $0 == "," }).count > 1 {
            return false
        }
        
        if let commaIndex = newText.firstIndex(of: ","), newText[newText.index(after: commaIndex)...].count > 2 {
            return false
        }
        return true
    }
}
