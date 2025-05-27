//
//  PaymentHandler.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 27.05.2025.
//

import PassKit

class PaymentHandler: NSObject {
    
    var paymentStatus = PKPaymentAuthorizationStatus.failure
    var completionHandler: ((Bool) -> Void)!

    static let supportedNetworks: [PKPaymentNetwork] = [
        .masterCard,
        .visa
    ]

    class func applePayStatus() -> (canMakePayments: Bool, canSetupCards: Bool) {
        return (PKPaymentAuthorizationController.canMakePayments(),
                PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks))
    }
    
    func startPayment(sum: Double, title: String, completion: @escaping (Bool) -> Void) {
        self.completionHandler = completion
        
        let paymentSummaryItem = PKPaymentSummaryItem(
            label: "Благодійний внесок на збір \"\(title)\"",
            amount: NSDecimalNumber(string: "\(sum)"),
            type: .final
        )
        
        // Create a payment request.
        let paymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = [paymentSummaryItem]
        paymentRequest.merchantIdentifier = "merchant.test.sandbox"
        paymentRequest.merchantCapabilities = .threeDSecure
        paymentRequest.countryCode = "UA"
        paymentRequest.currencyCode = "UAH"
        paymentRequest.supportedNetworks = PaymentHandler.supportedNetworks
        
        // Display the payment request.
        let paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController.delegate = self
        paymentController.present(completion: { (presented: Bool) in
            if presented {
                debugPrint("Presented payment controller")
            } else {
                debugPrint("Failed to present payment controller")
                self.completionHandler(false)
            }
        })
    }
}

// Set up PKPaymentAuthorizationControllerDelegate conformance.

extension PaymentHandler: PKPaymentAuthorizationControllerDelegate {
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        
        // Perform basic validation on the provided contact information.
        let amount = payment.token.paymentData.count

        if amount % 2 == 0 {
            self.paymentStatus = .success
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        } else {
            let error = PKPaymentRequest.paymentContactInvalidError(withContactField: .postalAddress, localizedDescription: "Невірна адреса")
            self.paymentStatus = .failure
            completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
        }
    }
    
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss {
            // The payment sheet doesn't automatically dismiss once it has finished. Dismiss the payment sheet.
            DispatchQueue.main.async {
                if self.paymentStatus == .success {
                    self.completionHandler!(true)
                } else {
                    self.completionHandler!(false)
                }
            }
        }
    }
}
