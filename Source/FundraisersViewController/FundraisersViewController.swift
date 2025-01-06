//
//  FundraisersViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 05.01.2025.
//

import UIKit

class FundraisersViewController: UIViewController {
    @IBOutlet var openFundraisersStack: UIStackView!
    @IBOutlet var closedFundraisersStack: UIStackView!
    
    let closeDateFormatter = DateFormatter()
  
    var openFundraisers: [ListElementModel] = []
    var closedFundraisers: [ListElementModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        closeDateFormatter.dateFormat = "dd.MM.yyyy"
        initFundraisers()
        
        openFundraisers.forEach { fundraiser in
            addListElementIntoStack(listElement: fundraiser, stack: openFundraisersStack)
        }
        
        closedFundraisers.forEach { fundraiser in
            addListElementIntoStack(listElement: fundraiser, stack: closedFundraisersStack)
        }
    }
    
    private func initFundraisers() {
        openFundraisers = [
            ListElementModel(id: 1, title: "Rusoriz1", goal: 10000, amount: 241.86, status: .open),
            ListElementModel(id: 2, title: "Rusoriz2", goal: 20000, amount: 11230.51, status: .open),
            ListElementModel(id: 3, title: "Rusoriz3", goal: 1000000, amount: 592313.01, status: .open),
            ListElementModel(id: 4, title: "Rusoriz4", goal: 50000, amount: 41230.89, status: .open),
        ]
        
        closedFundraisers = [
            ListElementModel(id: 5, title: "Rusoriz5", goal: 17000, amount: 17521.45, status: .closed(closeDate: closeDateFormatter.date(from: "11.12.2024")!)),
            ListElementModel(id: 6, title: "Rusoriz6", goal: 20000, amount: 19120.51, status: .closed(closeDate: closeDateFormatter.date(from: "06.09.2024")!)),
            ListElementModel(id: 7, title: "Rusoriz7", goal: 10000, amount: 8701.19, status: .closed(closeDate: closeDateFormatter.date(from: "04.01.2025")!)),
            ListElementModel(id: 8, title: "Rusoriz8", goal: 45000, amount: 45130.89, status: .closed(closeDate: closeDateFormatter.date(from: "18.10.2024")!)),
        ]
        
        openFundraisers = openFundraisers.sorted { $0.amount / $0.goal > $1.amount / $1.goal }
        closedFundraisers = closedFundraisers.sorted { (fundraiser1, fundraiser2) -> Bool in
            switch (fundraiser1.status, fundraiser2.status) {
            case (.closed(let closeDate1), .closed(let closeDate2)):
                return closeDate1 > closeDate2
            case (.closed, _):
                return true
            default:
                return false
            }
        }
    }
    
    private func addListElementIntoStack(listElement: ListElementModel, stack: UIStackView) {
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
