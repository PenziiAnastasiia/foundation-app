//
//  FundraisersViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 05.01.2025.
//

import UIKit
import FirebaseFirestore

class FundraisersListViewController: UIViewController, KeyboardObservable, UITableViewDataSource, UITableViewDelegate, FilterViewControllerDelegate {
    
    @IBOutlet weak var fundraisersTableView: UITableView!
    
    var scrollViewToAdjust: UIScrollView? {
        return self.fundraisersTableView
    }
    
    private var fundraisersList: [FundraiserModel] = []
    private var openFundraisers: [FundraiserModel] = []
    private var closedFundraisers: [FundraiserModel] = []
    private var filters = FiltersModel.createEmptyModel()
    private var updateTimer: Timer?
    private var searchBar: UISearchBar?
    private var filterButton: UIBarButtonItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchBar = self.setupSearchBarWithFilter(placeholder: "Пошук зборів", filterAction: #selector(self.didTapFilter))
        self.enableHideKeyboardOnTap()
        self.startObservingKeyboard()
        
        let separatortCell = UINib(nibName: "FundraisersSeparatorTableViewCell", bundle: nil)
        let listElementCell = UINib(nibName: "ListElementTableViewCell", bundle: nil)
        
        self.fundraisersTableView.register(separatortCell, forCellReuseIdentifier: "SeparatorCell")
        self.fundraisersTableView.register(listElementCell, forCellReuseIdentifier: "ListElementCell")
        
        self.fundraisersTableView.dataSource = self
        self.fundraisersTableView.delegate = self
        
        Task {
            await self.fillFundraisersList()
            
            DispatchQueue.main.async {
                self.fundraisersTableView.reloadData()
                self.startUpdateTimer()
            }
        }
    }

    deinit {
        self.stopObservingKeyboard()
    }
    
    
    // MARK: - private
    
    @objc private func didTapFilter() {
        let controller = FilterViewController(filters: self.filters)
        controller.delegate = self
        controller.modalPresentationStyle = .pageSheet
        self.present(controller, animated: true)
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
              let collected = document["collected"] as? Double,
              let purposeTags = document["purposeTags"] as? [String]
        else { return nil }
        
        let descriptionMedia = document["descriptionMedia"] as? [String]
        let closeDate = (document["closeDate"] as? Timestamp)?.dateValue()
        
        let fundraiser = FundraiserModel(id: id, title: title, description: description, descriptionMedia: descriptionMedia, goal: goal, collected: collected, openDate: openDate, closeDate: closeDate, purposeTags: purposeTags)
        
        return fundraiser
    }

    private func filterList() {
        let filtered = self.fundraisersList
            .filter { FilterEngine.matchesFilters($0, filters: self.filters) }
            .filter { self.matchesSearch($0) }
        
        self.closedFundraisers = filtered
            .filter { $0.closeDate != nil }
            .sorted { $0.closeDate! > $1.closeDate! }
        
        self.openFundraisers = filtered
            .filter { $0.closeDate == nil }
            .sorted { $0.collected / Double($0.goal) > $1.collected / Double($1.goal) }
    }
    
    private func matchesSearch(_ fundraiser: FundraiserModel) -> Bool {
        guard let searchText = self.searchBar?.text?.lowercased(), !searchText.isEmpty else {
            return true
        }
        return fundraiser.title.lowercased().contains(searchText) ||
               fundraiser.description.lowercased().contains(searchText)
    }
    
    private func startUpdateTimer() {
        self.updateTimer?.invalidate()
        self.updateTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.updateFundraisersData), userInfo: nil, repeats: true)
    }

    @objc private func updateFundraisersData() {
        Task {
            await self.fillFundraisersList()

            DispatchQueue.main.async {
                self.fundraisersTableView.reloadData()
            }
        }
    }

    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.filterList()
        return section == 0 ? self.openFundraisers.count + 1 : self.closedFundraisers.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        if indexPath.row == 0 {
            let separatorText = indexPath.section == 0 ? "Активні збори" : "Закриті збори"
            let editConstraint = indexPath.section == 0 ? false : true
            cell = (tableView.dequeueReusableCell(withIdentifier: "SeparatorCell", for: indexPath) as? FundraisersSeparatorTableViewCell)
                .flatMap {
                    $0.configure(with: separatorText, editConstraint)
                    return $0
                }
        } else {
            cell = (tableView.dequeueReusableCell(withIdentifier: "ListElementCell", for: indexPath) as? ListElementTableViewCell)
                .flatMap {
                    if let model = (indexPath.section == 0 ? self.openFundraisers : self.closedFundraisers).object(at: indexPath.row - 1) {
                        $0.configure(with: model)
                        return $0
                    }
                    return nil
                }
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { return }
        
        if let model = (indexPath.section == 0 ? self.openFundraisers : self.closedFundraisers).object(at: indexPath.row - 1) {
            let controller = FundraiserDetailsViewController(fundraiser: model)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 { return }
        
        if let listCell = cell as? ListElementTableViewCell {
            if let model = self.openFundraisers.object(at: indexPath.row - 1) {
                listCell.configure(with: model)
            }
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.fundraisersTableView.reloadData()
    }
    
    // MARK: - FilterViewControllerDelegate
    
    func filterViewControllerDidApply(_ controller: FilterViewController, filters: FiltersModel) {
        self.filters = filters
        self.fundraisersTableView.reloadData()
    }
}
