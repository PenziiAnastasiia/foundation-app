//
//  ReportsListViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 22.04.2025.
//

import Foundation

import UIKit
import FirebaseFirestore

class ReportsListViewController: UIViewController, KeyboardObservable, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var reportsTableView: UITableView!
    
    var scrollViewToAdjust: UIScrollView? {
        return self.reportsTableView
    }
    
    private var reportsList: [ReportModel] = []
    private var filteredReportsList: [ReportModel] = []
    private var updateTimer: Timer?
    private var searchBar: UISearchBar?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isHidden = true

        self.searchBar = self.setupSearchBarWithFilter(placeholder: "Пошук звітів", filterAction: #selector(self.didTapFilter))
        
        self.enableHideKeyboardOnTap()
        self.startObservingKeyboard()
        
        let listElementCell = UINib(nibName: "ListElementTableViewCell", bundle: nil)
        self.reportsTableView.register(listElementCell, forCellReuseIdentifier: "ListElementCell")
        
        self.reportsTableView.dataSource = self
        self.reportsTableView.delegate = self
        
        Task {
            await self.fillReportsList()
            
            DispatchQueue.main.async {
                self.reportsTableView.reloadData()
                self.view.isHidden = false
                self.startUpdateTimer()
            }
        }
    }
    
    deinit {
        self.stopObservingKeyboard()
    }
    
    @objc private func didTapFilter() {
        print("Filter button tapped")
    }
    
    private func fillReportsList() async {
        do {
            self.reportsList = []
            let db = Firestore.firestore()
            let querySnapshot = try await db.collection("Fundraisers").getDocuments()
            
            for document in querySnapshot.documents {
                if let report = await self.createReport(from: document.data(), with: document.documentID) {
                    self.reportsList.append(report)
                }
            }
        } catch {
            print("Error fetching reports data: \(error)")
        }
    }
    
    private func createReport(from document: [String: Any], with id: String) async -> ReportModel? {
        guard let title = document["title"] as? String,
              let description = document["reportDescription"] as? String,
              let closeDate = (document["closeDate"] as? Timestamp)?.dateValue(),
              let collected = document["collected"] as? Double
        else { return nil }
        
        let reportMediaNames = document["reportMedia"] as? [String]
        
        let report = ReportModel(id: id, title: title, description: description, collected: collected, closeDate: closeDate, reportMediaNames: reportMediaNames)
        
        return report
    }

    private func filterList() {
        let searchText = self.searchBar?.text?.lowercased() ?? ""
        self.filteredReportsList = searchText.isEmpty
            ? self.reportsList
            : self.reportsList.filter { report in
                    let titleMatch = report.title.lowercased().contains(searchText)
                    let descriptionMatch = report.description.lowercased().contains(searchText)
                    return titleMatch || descriptionMatch
                }
        self.filteredReportsList.sort { $0.closeDate > $1.closeDate }
    }
    
    private func startUpdateTimer() {
        self.updateTimer?.invalidate()
        self.updateTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.updateFundraisersData), userInfo: nil, repeats: true)
    }

    @objc private func updateFundraisersData() {
        Task {
            await self.fillReportsList()

            DispatchQueue.main.async {
                self.reportsTableView.reloadData()
            }
        }
    }
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.filterList()
        return self.filteredReportsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "ListElementCell", for: indexPath) as? ListElementTableViewCell)
            .flatMap {
                if let model = self.filteredReportsList.object(at: indexPath.row) {
                    $0.configure(with: model)
                    return $0
                }
                return nil
            }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let model = self.filteredReportsList.object(at: indexPath.row) {
            let controller = ReportDetailsViewController(report: model)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension ReportsListViewController {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.reportsTableView.reloadData()
    }
}
