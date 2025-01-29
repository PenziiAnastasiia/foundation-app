//
//  FundraisersViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 05.01.2025.
//

import UIKit
import FirebaseFirestore

class FundraisersListViewController: UIViewController {
    @IBOutlet var openFundraisersStack: UIStackView!
    @IBOutlet var closedFundraisersStack: UIStackView!
    
    private var jars: [[String : Any]] = []
    private var fundraisersList: [FundraiserListElement] = []
    private var updateTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isHidden = true
        
        Task {
            await self.fillFundraisersList()
            
            DispatchQueue.main.async {
                self.fillStacks()
                self.view.isHidden = false
                self.startUpdateTimer()
            }
        }
    }
    
    private func fillFundraisersList() async {
        do {
            self.fundraisersList = []
            self.jars = try await getClientJarsInfo()
            let db = Firestore.firestore()
            let querySnapshot = try await db.collection("Fundraisers").getDocuments()
            
            for document in querySnapshot.documents {
                if let fundraiser = await self.createFundraiser(from: document) {
                    self.fundraisersList.append(fundraiser)
                }
            }
        } catch {
            print("Error fetching fundraisers data: \(error)")
        }
    }
    
    private func getClientJarsInfo() async throws -> [[String: Any]] {
        guard let url = URL(string: "https://api.monobank.ua/personal/client-info") else { throw NSError(domain: "Invalid URL", code: 1, userInfo: nil) }
        let XToken = ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(XToken, forHTTPHeaderField: "X-Token")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let jars = json["jars"] as? [[String: Any]] else {
            throw NSError(domain: "Invalid response", code: 2, userInfo: nil)
        }
        
        return jars
    }
    
    private func createFundraiser(from document: QueryDocumentSnapshot) async -> FundraiserListElement? {
        guard let id = Int(document.documentID), let title = document.data()["title"] as? String else { return nil }
        let closeDate = (document.data()["closeDate"] as? Timestamp)?.dateValue()
        
        let fundraiser = FundraiserListElement(id: id, title: title, goal: 0, amount: 0.0, closeDate: closeDate)
        
        if let url = (document.data()["linkAPI"] as? String).flatMap({ URL(string: $0) }) {
            do {
                let (goal, amount) = try await self.getValuesFromJar(url: url)
                return fundraiser.setAmountValue(amount).setGoalValue(goal)
            } catch {
                print("Error fetching jar data from API: \(error)")
            }
        } else if let jarLink = document.data()["jarLink"] as? String,
                    let sendId = jarLink.components(separatedBy: "/").last {
            let jarInfo = self.findJarInfo(for: sendId)

            if let jarInfo = jarInfo, let amount = jarInfo["balance"] as? Double, let goal = jarInfo["goal"] as? Int {
                return fundraiser.setAmountValue(amount / 100).setGoalValue(goal / 100)   // перевід копійок в гривні
            } else if let amount = document.data()["collected"] as? Double {
                return fundraiser.setAmountValue(amount)
            }
        }
        return nil
    }
    
    private func getValuesFromJar(url: URL) async throws -> (Int, Double) {
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        
        guard let goal = json?["goal"] as? Int, let amount = json?["amount"] as? Double else {
            throw NSError(domain: "Invalid data", code: 1, userInfo: nil)
        }
        
        return (goal / 100, amount / 100)   // перевід копійок в гривні
    }
    
    private func findJarInfo(for sendId: String) -> [String: Any]? {
        return self.jars.first { jar in
            guard let currentSendId = (jar["sendId"] as? String)?.components(separatedBy: "/").last else { return false }
            return currentSendId == sendId
        }
    }

    private func fillStacks() {
        let closedFundraisers = self.fundraisersList
            .filter { $0.closeDate != nil }
            .sorted { $0.closeDate! > $1.closeDate! }
        
        let openFundraisers = self.fundraisersList
            .filter { $0.closeDate == nil }
            .sorted { $0.amount / Double($0.goal) > $1.amount / Double($1.goal) }
        
        self.closedFundraisersStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        closedFundraisers.forEach { self.addListElementIntoStack(listElement: $0, stack: self.closedFundraisersStack) }
        
        self.openFundraisersStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        openFundraisers.forEach { self.addListElementIntoStack(listElement: $0, stack: self.openFundraisersStack) }
    }
    
    private func addListElementIntoStack(listElement: FundraiserListElement, stack: UIStackView) {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height * 0.1
        
        if let listElementView = ListElementView.loadFromNib() {
            listElementView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            listElementView.layer.cornerRadius = height / 5
            listElementView.fillView(with: listElement, action: { [weak self] id in
                let controller = FundraiserDetailsViewController(fundraiser: listElement)
                self?.navigationController?.pushViewController(controller, animated: true)
            })
            stack.addArrangedSubview(listElementView)
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
