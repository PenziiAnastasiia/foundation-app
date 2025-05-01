//
//  ReportsListViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 22.04.2025.
//

import Foundation

import UIKit
import FirebaseFirestore

class ReportsListViewController: UIViewController, KeyboardObservable {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var reportsStack: UIStackView!
    
    var scrollViewToAdjust: UIScrollView? {
        return self.scrollView
    }
    
    private var reportsList: [ReportModel] = []
    private var filteredReportsList: [ReportModel] = []
    private var updateTimer: Timer?
    private var searchBar: UISearchBar?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isHidden = true

        self.searchBar = self.setupSearchBarWithFilter(placeholder: "Пошук звітів", filterAction: #selector(self.didTapFilter))
        self.startObservingKeyboard()
        
        Task {
            await self.fillReportsList()

            DispatchQueue.main.async {
                self.fillStack()
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

    private func fillStack() {
        let searchText = self.searchBar?.text?.lowercased() ?? ""
        if !searchText.isEmpty {
            self.filteredReportsList = self.reportsList.filter { report in
                let titleMatch = report.title.lowercased().contains(searchText)
                let descriptionMatch = report.description.lowercased().contains(searchText)
                return titleMatch || descriptionMatch
            }
        } else {
            self.filteredReportsList = self.reportsList
        }
        
        self.reportsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        self.filteredReportsList.sorted { $0.closeDate > $1.closeDate }.forEach { self.addListElementIntoStack(listElement: $0) }
    }
    
    private func addListElementIntoStack(listElement: ReportModel) {
        if let listElementView = ListElementView.loadFromNib() {
            self.reportsStack.addArrangedSubview(listElementView)
            listElementView.layer.cornerRadius = listElementView.frame.width / 25
            listElementView.addBarView()
            listElementView.fillView(with: listElement, action: { [weak self] in
                let controller = ReportDetailsViewController(report: listElement)
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
            await self.fillReportsList()

            DispatchQueue.main.async {
                self.fillStack()
            }
        }
    }
}

extension ReportsListViewController {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.fillStack()
    }
}
