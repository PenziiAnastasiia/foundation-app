//
//  AccountPageViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 29.04.2025.
//

import UIKit

class AccountPageViewController: UIViewController, KeyboardObservable, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var donationHistoryTableView: UITableView!
    
    var scrollViewToAdjust: UIScrollView? {
        return self.donationHistoryTableView
    }
    
    private var searchBar: UISearchBar?
    private var donationItems: [DonationModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar = self.setupSearchBarWithFilter(placeholder: "Пошук", filterAction: #selector(self.didTapFilter))
        
        let donationCell = UINib(nibName: "DonationHistoryTableViewCell", bundle: nil)
        let infoCell = UINib(nibName: "UserInfoViewCell", bundle: nil)

        self.donationHistoryTableView.register(donationCell, forCellReuseIdentifier: "DonationCell")
        self.donationHistoryTableView.register(infoCell, forCellReuseIdentifier: "UserInfoCell")
        
        self.donationHistoryTableView.dataSource = self
        self.donationHistoryTableView.delegate = self
        
        self.donationItems = [
            DonationModel(fundraiserTitle: "1keeihehkqekjekje", donate: 109.2, date: Date()),
            DonationModel(fundraiserTitle: "393919eihf diuwhjfgql jeh1u39 u9 31y 8ey 0fjofpw0if fjf fiwo0f9", donate: 1.25, date: Date()),
            DonationModel(fundraiserTitle: "djdjkssofjfo3947rh", donate: 10902.98, date: Date()),
            DonationModel(fundraiserTitle: "4o0ejjdjwijdqodjfqejied9nd", donate: 5555, date: Date()),
        ]
        
        self.donationHistoryTableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.startObservingKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopObservingKeyboard()
    }
    
    @objc private func didTapFilter() {
        print("Filter button tapped")
    }


    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.donationItems.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "UserInfoCell", for: indexPath) as? UserInfoViewCell
     
        default:
            cell = (tableView.dequeueReusableCell(withIdentifier: "DonationCell", for: indexPath) as? DonationHistoryTableViewCell)
                .flatMap {
                    if let model = self.donationItems.object(at: indexPath.row - 1) {
                        $0.configure(with: model)
                        
                        return $0
                    }
                    return nil
                }
        }
        
        return cell ?? UITableViewCell()
    }
}
