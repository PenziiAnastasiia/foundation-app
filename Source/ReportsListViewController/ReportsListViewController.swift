//
//  ReportsListViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 22.04.2025.
//

import Foundation

import UIKit
import FirebaseFirestore

class ReportsListViewController: UIViewController {
    @IBOutlet weak var reportsStack: UIStackView!
    
    private var reportsList: [ReportModel] = []
    private var updateTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isHidden = true

        let searchBar = UISearchBar()
        searchBar.placeholder = "Пошук звітів"
        searchBar.tintColor = .container
        
        let filterButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease"),
            style: .plain,
            target: self,
            action: #selector(didTapFilter)
        )
        
        navigationItem.titleView = searchBar
        navigationItem.rightBarButtonItem = filterButton
        
        Task {
            await self.fillReportsList()

            DispatchQueue.main.async {
                self.fillStack()
                self.view.isHidden = false
                self.startUpdateTimer()
            }
        }
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
              let closeDate = (document["closeDate"] as? Timestamp)?.dateValue(),
              let reportMediaNames = document["reportMedia"] as? [String],
              let collected = document["collected"] as? Double
        else { return nil }
        
        let report = ReportModel(id: id, title: title, description: description, collected: collected, closeDate: closeDate, reportMediaNames: reportMediaNames)
        
        return report
    }

    private func fillStack() {
        self.reportsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        self.reportsList.sorted { $0.closeDate > $1.closeDate }.forEach { self.addListElementIntoStack(listElement: $0) }
    }
    
    private func addListElementIntoStack(listElement: ReportModel) {
        if let listElementView = ListElementView.loadFromNib() {
            self.reportsStack.addArrangedSubview(listElementView)
            listElementView.layer.cornerRadius = listElementView.bounds.width / 25
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
