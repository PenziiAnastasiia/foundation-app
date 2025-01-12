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
        
        Task {
            let documents = try await self.getDocuments()
            await self.fillFundraisersList(documents: documents)
            self.fillStacks()
        }
    }
    
    private func fillFundraisersList(documents: [QueryDocumentSnapshot]) async {
        for doc in documents {
            guard
                let id = Int(doc.documentID),
                let title = doc.data()["title"] as? String,
                let isClosed = doc.data()["isClosed"] as? Bool
            else { return }
            
            let closeDate = (doc.data()["closeDate"] as? Timestamp)?.dateValue()
            
            if let url = (doc.data()["linkAPI"] as? String).flatMap({ URL(string: $0) }) {
                do {
                    let (goal, amount) = try await self.getValuesFromJar(url: url)
                    self.fundraisersList.append(FundraiserListElement(id: id, title: title, goal: goal, amount: amount, closeDate: closeDate))
                } catch {
                    print(error)
                }
            } else {
                guard
                    let goal = doc.data()["goal"] as? Int,
                    let amount = doc.data()["amount"] as? Double
                else { return }
                
                self.fundraisersList.append(FundraiserListElement(id: id, title: title, goal: goal, amount: amount, closeDate: closeDate))
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
    
    private func fillStacks() {
        let closedFundraisers = self.fundraisersList
            .filter { $0.closeDate != nil }
            .sorted { $0.closeDate! < $1.closeDate! }
        
        let openFundraisers = self.fundraisersList
            .filter { $0.closeDate == nil }
            .sorted { $0.amount / Double($0.goal) > $1.amount / Double($1.goal) }
        
        closedFundraisers.forEach { fundraiserListElement in
            DispatchQueue.main.async {
                self.addListElementIntoStack(listElement: fundraiserListElement, stack: self.closedFundraisersStack)
            }
        }
        
        openFundraisers.forEach { fundraiserListElement in
            DispatchQueue.main.async {
                self.addListElementIntoStack(listElement: fundraiserListElement, stack: self.openFundraisersStack)
            }
        }
    }
    
    private func addListElementIntoStack(listElement: FundraiserListElement, stack: UIStackView) {
        if let listElementView = ListElementView.loadFromNib() {
            let width = UIScreen.main.bounds.width
            let height = UIScreen.main.bounds.height * 0.1
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
