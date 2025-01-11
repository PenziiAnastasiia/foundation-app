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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getDocuments { documents in
            self.createFundraiserListElements(documents: documents)
        }
    }
    
    private func createFundraiserListElements(documents: [QueryDocumentSnapshot]) {
        documents.forEach { doc in
            guard
                let id = Int(doc.documentID),
                let title = doc.data()["title"] as? String,
                let isClosed = doc.data()["isClosed"] as? Bool
            else { return }
            
            let goal: Int
            let amount: Double
            var closeDate: Date? = nil
            
            if isClosed {
                guard
                    let docGoal = doc.data()["goal"] as? Int,
                    let docAmount = doc.data()["amount"] as? Double,
                    let timestamp = doc.data()["closeDate"] as? Timestamp
                else { return }
                
                goal = docGoal
                amount = docAmount
                closeDate = timestamp.dateValue()
            } else {
                (goal, amount) = self.getValuesFromJar()
            }
            
            let fundraiserListElement = FundraiserListElement(id: id, title: title, goal: goal, amount: amount, closeDate: closeDate)
            
            self.addListElementIntoStack(listElement: fundraiserListElement, stack: (closeDate != nil) ? self.closedFundraisersStack : self.openFundraisersStack)
        }
    }
    
    private func getDocuments(completion: @escaping ([QueryDocumentSnapshot]) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("Fundraisers").getDocuments { (snapshot, error) in
            if let error = error {
               print("Error getting documents: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found.")
                return
            }
            
            completion(documents)
        }
    }
    
    private func getValuesFromJar() -> (Int, Double) {
        return (100000, 50239.1)
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
