//
//  ReportsListViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 22.04.2025.
//

import Foundation
import UIKit

class ReportsListViewController: UIViewController, KeyboardObservable, UITableViewDataSource, UITableViewDelegate, FilterViewControllerDelegate {
    
    @IBOutlet weak var reportsTableView: UITableView!
    
    var scrollViewToAdjust: UIScrollView? {
        return self.reportsTableView
    }
    
    private var reportsList: [ReportModel] = []
    private var filteredReportsList: [ReportModel] = []
    private var filters = FiltersModel.createEmptyModel()
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
            self.reportsList = await FirestoreService.shared.getReportsList()
            
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
        let controller = FilterViewController(forReports: true, filters: self.filters)
        controller.delegate = self
        controller.modalPresentationStyle = .pageSheet
        self.present(controller, animated: true)
    }

    private func filterList() {
        self.filteredReportsList = self.reportsList
            .filter { FilterEngine.matchesFilters($0, filters: self.filters) }
            .filter { self.matchesSearch($0) }
            .sorted { $0.publicationDate > $1.publicationDate }
    }
    
    private func matchesSearch(_ report: ReportModel) -> Bool {
        guard let searchText = self.searchBar?.text?.lowercased(), !searchText.isEmpty else {
            return true
        }
        return report.title.lowercased().contains(searchText) ||
               report.description.lowercased().contains(searchText)
    }
    
    private func startUpdateTimer() {
        self.updateTimer?.invalidate()
        self.updateTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.updateFundraisersData), userInfo: nil, repeats: true)
    }

    @objc private func updateFundraisersData() {
        Task {
            self.reportsList = await FirestoreService.shared.getReportsList()

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

    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.reportsTableView.reloadData()
    }
    
    // MARK: - FilterViewControllerDelegate
    
    func filterViewControllerDidApply(_ controller: FilterViewController, filters: FiltersModel) {
        self.filters = filters
        self.reportsTableView.reloadData()
    }
}
