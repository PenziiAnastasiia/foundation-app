//
//  PDFGenerator.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 21.05.2025.
//

import TPPDF

class PDFGeneratorService {
    
    static func generateInvoice(amount: Double, fundraiser: String, completion: @escaping (URL?) -> Void) {
        let invoiceNumber = Int.random(in: 100000...999999)
        let date = DateFormatter.shared.string(from: Date())
        
        let document = PDFDocument(format: .a4)
        
        self.addTitle(in: document, "РАХУНОК-ФАКТУРА №\(invoiceNumber)", on: date)
        self.addRecipientPayer(in: document, with: invoiceNumber, to: fundraiser, on: date)
        self.addDescribingTable(in: document, amount: amount)
        document.add(.contentRight, text: "Разом: \(String(format: "%.2f грн", amount))")
        self.addSigningFields(in: document)
        
        let fileName = "Invoice_\(invoiceNumber).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        let generator = PDFGenerator(document: document)
        do {
            try generator.generate(to: url)
            completion(url)
        } catch {
            print("Помилка генерації PDF: \(error)")
            completion(nil)
        }
    }
    
    static func generateReceipt(donation: DonationModel, completion: @escaping (URL?) -> Void) {
        let document = PDFDocument(format: .a4)
        
        self.addTitle(in: document, "Квитанція за сплату №\(donation.receiptNumber)", on: DateFormatter.shared.string(from: donation.date))
        document.add(.contentLeft, text: "Благодійний внесок на підтримку Збору:")
        document.add(.contentLeft, text: "\"\(donation.fundraiserTitle)\"")
        self.addReceiptInfo(in: document, amount: donation.amount)
        self.addSigningFields(in: document)
        
        let fileName = "Receipt_\(donation.receiptNumber).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        let generator = PDFGenerator(document: document)
        do {
            try generator.generate(to: url)
            completion(url)
        } catch {
            print("Помилка генерації PDF: \(error)")
            completion(nil)
        }
    }
    
    // MARK: - private
    
    static private func addTitle(in document: PDFDocument, _ text: String, on date: String) {
        document.add(.contentCenter, attributedTextObject: PDFAttributedText(text: self.getAttributedText(text, size: 24)))
        document.add(.contentCenter, attributedTextObject: PDFAttributedText(text: self.getAttributedText("від \(date)", size: 24)))
        document.add(.contentLeft, text: " ")
    }
    
    static private func addRecipientPayer(in document: PDFDocument, with invoiceNumber: Int, to fundraiser: String, on date: String) {
        guard let user = UserManager.shared.currentUser,
              let organizationName = user.organizationName,
              let edrpoy = user.EDRPOY,
              let address = user.address,
              let phone = user.phoneNumber
        else { return }
        
        document.add(.contentLeft, attributedTextObject: PDFAttributedText(text: self.getAttributedText("Одержувач благодійного внеску:", size: 16)))
        document.add(.contentLeft, text: "Благодійний фонд \"\(FoundationInfoManager.shared.name)\"")
        document.add(.contentLeft, text: "IBAN: \(FoundationInfoManager.shared.iban)")
        document.add(.contentLeft, text: "ЄДРПОУ: \(FoundationInfoManager.shared.edrpoy)")
        document.add(.contentLeft, text: "Банк: \(FoundationInfoManager.shared.bank)")
        document.add(.contentLeft, text: "Адреса: \(FoundationInfoManager.shared.address)")
        document.add(.contentLeft, text: "Номер тел.: \(FoundationInfoManager.shared.phone)")
        document.add(.contentLeft, text: "Email: \(FoundationInfoManager.shared.email)")
        document.add(.contentLeft, text: "Директор: \(FoundationInfoManager.shared.pib)")
        
        document.add(.contentLeft, text: " ")
        
        document.add(.contentLeft, attributedTextObject: PDFAttributedText(text: self.getAttributedText("Платник:", size: 16)))
        document.add(.contentLeft, text: "\(organizationName)")
        document.add(.contentLeft, text: "ЄДРПОУ: \(edrpoy)")
        document.add(.contentLeft, text: "Адреса: \(address)")
        document.add(.contentLeft, text: "Номер тел.: \(phone)")
        document.add(.contentLeft, text: "Представник: \(user.PIB)")
        
        document.add(.contentLeft, text: " ")
        
        document.add(.contentLeft, text: "Призначення платежу:\nБлагодійний внесок на підтримку Збору \"\(fundraiser)\", згідно рахунку №\(invoiceNumber) від \(date)")
        
        document.add(.contentLeft, text: " ")
    }
    
    static private func addReceiptInfo(in document: PDFDocument, amount: Double) {
        guard let user = UserManager.shared.currentUser else { return }
        
        document.add(.contentLeft, text: " ")
        document.add(.contentLeft, attributedTextObject: PDFAttributedText(text: self.getAttributedText("Реквізити одержувача:", size: 16)))
        document.add(.contentLeft, text: FoundationInfoManager.shared.name)
        document.add(.contentLeft, text: "Код ЄДРПОУ: \(FoundationInfoManager.shared.edrpoy)")
        document.add(.contentLeft, text: "IBAN: \(FoundationInfoManager.shared.iban)")
        document.add(.contentLeft, text: "Банк: \(FoundationInfoManager.shared.bank)")
        document.add(.contentLeft, text: " ")
        
        document.add(.contentLeft, attributedTextObject: PDFAttributedText(text: self.getAttributedText("Платник:", size: 16)))
        if user.type == "individual" {
            document.add(.contentLeft, text: "ПІБ: \(user.PIB)")
            document.add(.contentLeft, text: "Спосіб оплати: Apple Pay")
        } else {
            document.add(.contentLeft, text: user.organizationName ?? "")
            document.add(.contentLeft, text: "Код ЄДРПОУ: \(user.EDRPOY ?? "")")
            document.add(.contentLeft, text: "Адреса: \(user.address ?? "")")
            document.add(.contentLeft, text: "Номер тел.: \(user.phoneNumber ?? "")")
        }
        document.add(.contentLeft, text: " ")
        document.add(.contentRight, attributedTextObject: PDFAttributedText(text: self.getAttributedText("Сума сплати: \(String(format: "%.2f грн", amount))", size: 24)))
    }
    
    static private func addDescribingTable(in document: PDFDocument, amount: Double) {
        let table: PDFTable = PDFTable(rows: 2, columns: 4)
        for column in 0..<4 {
            table[0,column].style = PDFTableCellStyle(colors: (fill: UIColor.lightGray, text: UIColor.black))
        }
        
        try? table[0,0].content = PDFTableContent(content: "Опис")
        try? table[0,1].content = PDFTableContent(content: "Кількість")
        try? table[0,2].content = PDFTableContent(content: "Ціна (грн)")
        try? table[0,3].content = PDFTableContent(content: "Сума (грн)")
        
        try? table[1,0].content = PDFTableContent(content: "Благодійний внесок")
        try? table[1,1].content = PDFTableContent(content: "1")
        try? table[1,2].content = PDFTableContent(content: String(format: "%.2f грн", amount))
        try? table[1,3].content = PDFTableContent(content: String(format: "%.2f грн", amount))
        
        table.widths = [0.4, 0.2, 0.2, 0.2]
        document.add(table: table)
    }
    
    static private func addSigningFields(in document: PDFDocument) {
        document.add(.contentRight, text: " ")
        document.add(.contentRight, text: " ")
        document.add(.contentRight, text: "Одержувач: ____________________________")
        document.add(.contentLeft, text: " ")
        document.add(.contentRight, text: "Платник: ____________________________")
    }
   
    static private func getAttributedText(_ text: String, size: CGFloat) -> NSAttributedString {
        NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.boldSystemFont(ofSize: size)
            ]
        )
    }
}
