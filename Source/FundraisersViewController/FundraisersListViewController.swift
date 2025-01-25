//
//  FundraisersViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 05.01.2025.
//

import UIKit
import FirebaseFirestore

class FundraisersListViewController: UIViewController {
    @IBOutlet var openFundraisersStack: UIStackView!
    @IBOutlet var closedFundraisersStack: UIStackView!
    
    var fundraisersList: [FundraiserListElement] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isHidden = true
        
        Task {
            let jars = try await self.getClientJarsInfo()
            let documents = try await self.getDocuments()
            await self.fillFundraisersList(documents: documents, jars: jars)
            
            DispatchQueue.main.async {
                self.fillStacks()
                self.view.isHidden = false
            }
        }
    }
    
    private func fillFundraisersList(documents: [QueryDocumentSnapshot], jars: [[String: Any]]) async {
        for doc in documents {
            guard let id = Int(doc.documentID), let title = doc.data()["title"] as? String else { return }
            let closeDate = (doc.data()["closeDate"] as? Timestamp)?.dateValue()
            
            if let url = (doc.data()["linkAPI"] as? String).flatMap({ URL(string: $0) }) {
                do {
                    let (goal, amount) = try await self.getValuesFromJar(url: url)
                    let fundraiser = FundraiserListElement(
                        id: id,
                        title: title,
                        goal: (closeDate == nil) ? goal : nil,
                        amount: amount,
                        closeDate: closeDate
                    )
                    self.fundraisersList.append(fundraiser)
                } catch {
                    print("Error fetching jar data from API: \(error)")
                }
            } else if let jarLink = doc.data()["jarLink"] as? String,
                        let sendId = jarLink.components(separatedBy: "/").last {
                let jarInfo = self.findJarInfo(for: sendId, in: jars)

                if let jarInfo = jarInfo, let amount = jarInfo["balance"] as? Double, let goal = jarInfo["goal"] as? Int {
                    let fundraiser = FundraiserListElement(
                        id: id,
                        title: title,
                        goal: (closeDate == nil) ? goal / 100 : nil,
                        amount: amount / 100,
                        closeDate: closeDate)
                    
                    self.fundraisersList.append(fundraiser)
                } else if let amount = doc.data()["amount"] as? Double {
                    let fundraiser = FundraiserListElement(
                        id: id,
                        title: title,
                        goal: nil,
                        amount: amount,
                        closeDate: closeDate)
                    
                    self.fundraisersList.append(fundraiser)
                }
            }
        }
    }
    
    private func getDocuments() async throws -> [QueryDocumentSnapshot] {
        let db = Firestore.firestore()
        
        return try await withCheckedThrowingContinuation { continuation in
            db.collection("Fundraisers").getDocuments { snapshot, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    continuation.resume(throwing: NSError(domain: "Firestore", code: 0, userInfo: [NSLocalizedDescriptionKey: "No documents found."]))
                    return
                }
                
                continuation.resume(returning: documents)
            }
        }
    }
    
    private func getValuesFromJar(url: URL) async throws -> (Int, Double) {
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        guard let goal = json?["goal"] as? Int, let amount = json?["amount"] as? Double else {
            throw NSError(domain: "Invalid data", code: 1, userInfo: nil)
        }
        
        return (goal / 100, amount / 100)
    }
    
    private func findJarInfo(for sendId: String, in jars: [[String: Any]]) -> [String: Any]? {
        return jars.first { jar in
            guard let currentSendId = (jar["sendId"] as? String)?.components(separatedBy: "/").last else { return false }
            return currentSendId == sendId
        }
    }
    
    private func getClientJarsInfo() async throws -> [[String: Any]] {
        guard let url = URL(string: "https://api.monobank.ua/personal/client-info") else { throw NSError(domain: "Invalid URL", code: 1, userInfo: nil) }
        let XToken = ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(XToken, forHTTPHeaderField: "X-Token")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let jars = json["jars"] as? [[String: Any]] else {
            throw NSError(domain: "Invalid response", code: 2, userInfo: nil)
        }
        
        return jars
    }
    
    private func fillStacks() {
        let closedFundraisers = self.fundraisersList
            .filter { $0.closeDate != nil }
            .sorted { $0.closeDate! > $1.closeDate! }
        
        let openFundraisers = self.fundraisersList
            .filter { $0.closeDate == nil }
            .sorted { $0.amount / Double($0.goal!) > $1.amount / Double($1.goal!) }
        
        closedFundraisers.forEach { fundraiserListElement in
            self.addListElementIntoStack(listElement: fundraiserListElement, stack: self.closedFundraisersStack)
        }
        
        openFundraisers.forEach { fundraiserListElement in
            self.addListElementIntoStack(listElement: fundraiserListElement, stack: self.openFundraisersStack)
        }
    }
    
    private func addListElementIntoStack(listElement: FundraiserListElement, stack: UIStackView) {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height * 0.1
        
        if let listElementView = ListElementView.loadFromNib() {
            listElementView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            listElementView.layer.cornerRadius = height / 5
            listElementView.fillView(with: listElement, action: { [weak self] id in
                let controller = FundraiserDetailsViewController(fundraiser: listElement)
                self?.navigationController?.pushViewController(controller, animated: true)
            })
            stack.addArrangedSubview(listElementView)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
