//
//  AccountPageViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 29.04.2025.
//

import UIKit

class AccountPageViewController: UIViewController, KeyboardObservable, UITableViewDataSource, UITableViewDelegate, UIDocumentInteractionControllerDelegate, FilterViewControllerDelegate {

    @IBOutlet weak var donationHistoryTableView: UITableView!
    
    var scrollViewToAdjust: UIScrollView? {
        return self.donationHistoryTableView
    }
    
    private var donationItems: [DonationModel] = []
    private var filteredDonationItems: [DonationModel] = []
    private var filters = FiltersModel.createEmptyModel()
    private var docController: UIDocumentInteractionController?
    private var searchBar: UISearchBar?
    private var filterButton: UIBarButtonItem?
    
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
    }

    override func viewWillAppear(_ animated: Bool) {
        if let uid = UserManager.shared.currentUID {
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
    
    // MARK: - private
    
    @objc private func didTapFilter() {
        let controller = FilterViewController(forDonations: true, filters: self.filters)
        controller.delegate = self
        controller.modalPresentationStyle = .pageSheet
        self.present(controller, animated: true)
    }
    
    private func filterList() {
        self.filteredDonationItems = self.donationItems
            .filter { FilterEngine.matchesFilters($0, filters: self.filters) }
            .filter { self.matchesSearch($0) }
            .sorted { $0.date > $1.date }
    }
    
    private func matchesSearch(_ donation: DonationModel) -> Bool {
        guard let searchText = self.searchBar?.text?.lowercased(), !searchText.isEmpty else {
            return true
        }
        return donation.fundraiserTitle.lowercased().contains(searchText)
    }
    
    private func getUserDonationHistory(_ uid: String) async throws -> [DonationModel] {
        try await withCheckedThrowingContinuation { continuation in
            FirestoreService.shared.getUserDonationHistory(uid: uid) { result in
                switch result {
                case .success(let donations):
                    continuation.resume(returning: donations)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func changeData() {
        let editProfileVC = EditProfileViewController()
        self.navigationController?.pushViewController(editProfileVC, animated: true)
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
        self.filterList()
        if let _ = UserManager.shared.currentUser {
            return self.filteredDonationItems.count + 1
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
                            userEmoji: user.emoji,
                            userName: user.PIB.components(separatedBy: " ").object(at: 1) ?? "Unknown",
                            userHistoryIsEmpty: self.filteredDonationItems.isEmpty,
                            changeData: self.changeData,
                            logout: self.logout
                        )
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
                    if let model = self.filteredDonationItems.object(at: indexPath.row - 1) {
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
        
        PDFGeneratorService.generateReceipt(donation: self.filteredDonationItems[indexPath.row - 1]) { url in
            guard let url = url else { return }
            
            DispatchQueue.main.async {
                self.docController = UIDocumentInteractionController(url: url)
                self.docController?.delegate = self
                self.docController?.presentPreview(animated: true)
            }
        }
    }
    
    // MARK: - UIDocumentInteractionControllerDelegate
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        self.docController = nil
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.donationHistoryTableView.reloadData()
    }
    
    // MARK: - FilterViewControllerDelegate
    
    func filterViewControllerDidApply(_ controller: FilterViewController, filters: FiltersModel) {
        self.filters = filters
        self.donationHistoryTableView.reloadData()
    }
}
