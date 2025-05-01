//
//  FundraisersViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 05.01.2025.
//

import UIKit
import FirebaseFirestore

class FundraisersListViewController: UIViewController, KeyboardObservable {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var openFundraisersStack: UIStackView!
    @IBOutlet weak var closedFundraisersStack: UIStackView!
    
    var scrollViewToAdjust: UIScrollView? {
        return self.scrollView
    }
    
    private var fundraisersList: [FundraiserModel] = []
    private var filteredFundraisersList: [FundraiserModel] = []
    private var updateTimer: Timer?
    private var searchBar: UISearchBar?
    private var filterButton: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isHidden = true

        self.searchBar = self.setupSearchBarWithFilter(placeholder: "Пошук зборів", filterAction: #selector(self.didTapFilter))
        self.startObservingKeyboard()
        
        Task {
            await self.fillFundraisersList()
            
            DispatchQueue.main.async {
                self.fillStacks()
                self.view.isHidden = false
                self.startUpdateTimer()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.enableHideKeyboardOnTap()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopObservingKeyboard()
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
                if let fundraiser = await self.createFundraiser(from: document.data(), with: document.documentID) {
                    self.fundraisersList.append(fundraiser)
                }
            }
        } catch {
            print("Error fetching fundraisers data: \(error)")
        }
    }
    
    private func createFundraiser(from document: [String: Any], with id: String) async -> FundraiserModel? {
        guard let title = document["title"] as? String,
              let description = document["description"] as? String,
              let openDate = (document["openDate"] as? Timestamp)?.dateValue(),
              let goal = document["goal"] as? Int,
              let collected = document["collected"] as? Double
        else { return nil }
        
        let descriptionMediaNames = document["descriptionMedia"] as? [String]
        let closeDate = (document["closeDate"] as? Timestamp)?.dateValue()
        
        let fundraiser = FundraiserModel(id: id, title: title, description: description, descriptionMediaNames: descriptionMediaNames, goal: goal, collected: collected, openDate: openDate, closeDate: closeDate)
        
        return fundraiser
    }

    private func fillStacks() {
        let searchText = self.searchBar?.text?.lowercased() ?? ""
        if !searchText.isEmpty {
            self.filteredFundraisersList = self.fundraisersList.filter { fundraiser in
                let titleMatch = fundraiser.title.lowercased().contains(searchText)
                let descriptionMatch = fundraiser.description.lowercased().contains(searchText)
                return titleMatch || descriptionMatch
            }
        } else {
            self.filteredFundraisersList = self.fundraisersList
        }
        
        let closedFundraisers = self.filteredFundraisersList
            .filter { $0.closeDate != nil }
            .sorted { $0.closeDate! > $1.closeDate! }
        
        let openFundraisers = self.filteredFundraisersList
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
            listElementView.layer.cornerRadius = listElementView.frame.width / 25
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

extension FundraisersListViewController {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        fillStacks()
    }
}
