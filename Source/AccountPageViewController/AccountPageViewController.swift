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
    private var uid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar = self.setupSearchBarWithFilter(placeholder: "Пошук в історії", filterAction: #selector(self.didTapFilter))
        
        self.enableHideKeyboardOnTap()
        self.startObservingKeyboard()
        
        let donationCell = UINib(nibName: "DonationHistoryTableViewCell", bundle: nil)
        let infoCell = UINib(nibName: "UserInfoViewCell", bundle: nil)

        self.donationHistoryTableView.register(donationCell, forCellReuseIdentifier: "DonationCell")
        self.donationHistoryTableView.register(infoCell, forCellReuseIdentifier: "UserInfoCell")
        
        self.donationHistoryTableView.dataSource = self
        self.donationHistoryTableView.delegate = self
        
        self.uid = UserManager.shared.currentUID
    }

    override func viewWillAppear(_ animated: Bool) {
        if let uid = self.uid {
            Task {
                do {
                    self.donationItems = try await self.getUserDonationHistory(uid)
                    self.donationHistoryTableView.reloadData()
                } catch {  }
            }
        }
    }
    
    deinit {
        self.stopObservingKeyboard()
    }
    
    @objc private func didTapFilter() {
        print("Filter button tapped")
    }
    
    // MARK: - private
    
    private func getUserDonationHistory(_ uid: String) async throws -> [DonationModel] {
        try await withCheckedThrowingContinuation { continuation in
            DonateService.shared.getUserDonationHistory(uid: uid) { result in
                switch result {
                case .success(let donations):
                    continuation.resume(returning: donations)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func logout() {
        AuthService.shared.signOut() { result in
            switch result {
            case .success:
                UserManager.shared.clearUser()
                DispatchQueue.main.async {
                    self.donationHistoryTableView.reloadData()
                }
            case .failure(_):
                self.showAlert(title: "Невідома помилка", message: "Повторіть спробу виходу пізніше")
            }
        }
    }

    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = UserManager.shared.currentUser {
            return self.donationItems.count + 1
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        switch indexPath.row {
        case 0:
            cell = (tableView.dequeueReusableCell(withIdentifier: "UserInfoCell", for: indexPath) as? UserInfoViewCell)
                .flatMap {
                    if let user = UserManager.shared.currentUser {
                        $0.configureWithLoggedInView(
                            userImage: UIImage(),
                            userName: user.PIB.components(separatedBy: " ").object(at: 1) ?? "Unknown",
                            userHistoryIsEmpty: self.donationItems.isEmpty,
                            logout: { [weak self] in self?.logout() })
                    } else {
                        $0.configureWithNotLoggedInView(onSignInTap: { [weak self] in
                            guard let self = self else { return }
                            let signInVC = SignInViewController()
                            self.navigationController?.pushViewController(signInVC, animated: true)
                        }, onSignUpTap: { [weak self] in
                            guard let self = self else { return }
                            let signUpVC = SignUpViewController()
                            self.navigationController?.pushViewController(signUpVC, animated: true)
                        })
                    }
                    return $0
                }
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
