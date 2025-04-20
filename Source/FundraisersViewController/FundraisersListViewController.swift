//
//  FundraisersViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 05.01.2025.
//

import UIKit
import FirebaseFirestore

class FundraisersListViewController: UIViewController {
    @IBOutlet weak var openFundraisersStack: UIStackView!
    @IBOutlet weak var closedFundraisersStack: UIStackView!
    
    private var fundraisersList: [FundraiserModel] = []
    private var updateTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isHidden = true

        let searchBar = UISearchBar()
        searchBar.placeholder = "Пошук зборів"
        
        let filterButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease"),
            style: .plain,
            target: self,
            action: #selector(didTapFilter)
        )
        
        navigationItem.titleView = searchBar
        navigationItem.rightBarButtonItem = filterButton
        
        Task {
            await self.fillFundraisersList()
            
            DispatchQueue.main.async {
                self.fillStacks()
                self.view.isHidden = false
                self.startUpdateTimer()
            }
        }
    }
    
    @objc private func didTapFilter() {
        print("Filter button tapped")
    }
    
    private func fillFundraisersList() async {
        do {
            self.fundraisersList = []
            let db = Firestore.firestore()
            let querySnapshot = try await db.collection("Fundraisers").getDocuments()
            
            for document in querySnapshot.documents {
                if let fundraiser = await self.createFundraiser(from: document) {
                    self.fundraisersList.append(fundraiser)
                }
            }
        } catch {
            print("Error fetching fundraisers data: \(error)")
        }
    }
    
    private func createFundraiser(from document: QueryDocumentSnapshot) async -> FundraiserModel? {
        guard let title = document.data()["title"] as? String,
              let description = document.data()["description"] as? String,
              let openDate = (document.data()["openDate"] as? Timestamp)?.dateValue(),
              let goal = document.data()["goal"] as? Int,
              let collected = document.data()["collected"] as? Double
        else { return nil }
        
        let id = document.documentID
        let closeDate = (document.data()["closeDate"] as? Timestamp)?.dateValue()
        
        let fundraiser = FundraiserModel(id: id, title: title, description: description, goal: goal, collected: collected, openDate: openDate, closeDate: closeDate)
        
        return fundraiser
    }

    private func fillStacks() {
        let closedFundraisers = self.fundraisersList
            .filter { $0.closeDate != nil }
            .sorted { $0.closeDate! > $1.closeDate! }
        
        let openFundraisers = self.fundraisersList
            .filter { $0.closeDate == nil }
            .sorted { $0.collected / Double($0.goal) > $1.collected / Double($1.goal) }
        
        self.closedFundraisersStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        closedFundraisers.forEach { self.addListElementIntoStack(listElement: $0, stack: self.closedFundraisersStack) }
        
        self.openFundraisersStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        openFundraisers.forEach { self.addListElementIntoStack(listElement: $0, stack: self.openFundraisersStack) }
    }
    
    private func addListElementIntoStack(listElement: FundraiserModel, stack: UIStackView) {
        if let listElementView = ListElementView.loadFromNib() {
            stack.addArrangedSubview(listElementView)
            listElementView.layer.cornerRadius = listElementView.bounds.width / 25
            listElementView.addBarView()
            listElementView.fillView(with: listElement, action: { [weak self] in
                let controller = FundraiserDetailsViewController(fundraiser: listElement)
                self?.navigationController?.pushViewController(controller, animated: true)
            })
        }
    }
    
    private func startUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateFundraisersData), userInfo: nil, repeats: true)
    }

    @objc private func updateFundraisersData() {
        Task {
            await self.fillFundraisersList()

            DispatchQueue.main.async {
                self.fillStacks()
            }
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
