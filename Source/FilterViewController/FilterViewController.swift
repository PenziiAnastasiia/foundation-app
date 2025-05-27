//
//  FilterViewController.swift
//  FoundationApp
//
//  Created by Анастасія Пензій on 24.05.2025.
//

import UIKit

class FilterViewController: UIViewController, KeyboardObservable, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var purposeTagsCollectionView: UICollectionView!
    @IBOutlet weak var amountFilterSwitch: UISwitch!
    @IBOutlet weak var amountFilterView: UIView!
    @IBOutlet weak var amountFromTextField: UITextField!
    @IBOutlet weak var amountToTextField: UITextField!
    @IBOutlet weak var amountErrorLabel: UILabel!
    @IBOutlet weak var stateFilterSwitch: UISwitch!
    @IBOutlet weak var stateFilterView: UIView!
    @IBOutlet weak var optionButton: UIButton!
    @IBOutlet weak var statePercentTextField: UITextField!
    @IBOutlet weak var stateErrorLabel: UILabel!
    @IBOutlet weak var dateFilterSwitch: UISwitch!
    @IBOutlet weak var dateFilterView: UIView!
    @IBOutlet weak var dateTagsCollectionView: UICollectionView!
    @IBOutlet weak var dateRangeFilterSwitch: UISwitch!
    @IBOutlet weak var dateRangeFilterView: UIView!
    @IBOutlet weak var dateFromTextField: UITextField!
    @IBOutlet weak var dateToTextField: UITextField!
    @IBOutlet weak var dateErrorLabel: UILabel!
    @IBOutlet weak var resetButtonView: UIView!
    
    var scrollViewToAdjust: UIScrollView? {
        return self.scrollView
    }
    
    weak var delegate: FilterViewControllerDelegate?
    
    private var forReports: Bool = false
    private var forDonations: Bool = false
    private var filters: FiltersModel
    private var datePicker: UIDatePicker?
    private var currentlyEditingTextField: UITextField?

    private var purposeTags = ["Дрони", "Авто", "Ремонт", "Гуманітарні потреби", "ППО", "РЕБ/РЕР системи", 
                               "Засоби звʼязку", "Засоби особистого захисту", "Медичне обладнання", "Реабілітація",
                               "Оптика/нічне бачення"]
    private var dateTags = ["Сьогодні", "За останні 7 днів", "За останній місяць", "В цьому році"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.enableHideKeyboardOnTap()
        self.startObservingKeyboard()
        
        self.configureTextFields()
        self.configureCollectionViewWithTags(self.purposeTagsCollectionView, allowsMultipleSelection: true)
        self.configureCollectionViewWithTags(self.dateTagsCollectionView, allowsMultipleSelection: false)
        self.configureInputView(for: [self.dateFromTextField, self.dateToTextField])
        
        if self.forReports {
            self.stateFilterSwitch.superview?.isHidden = true
            self.renameLabel(near: self.amountFilterSwitch, to: "За зібраною сумою")
            self.renameLabel(near: self.dateFilterSwitch, to: "За датою публікації")
        }
        
        if self.forDonations {
            self.stateFilterSwitch.superview?.isHidden = true
            self.renameLabel(near: self.amountFilterSwitch, to: "За сумою внеску")
            self.renameLabel(near: self.dateFilterSwitch, to: "За датою")
        }
        
        self.setFiltersConditions()
    }
    
    init(forReports: Bool = false, forDonations: Bool = false, filters: FiltersModel) {
        self.forReports = forReports
        self.forDonations = forDonations
        self.filters = filters
        super.init(nibName: "FilterViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.stopObservingKeyboard()
    }
    
    @IBAction func applyAction() {
        self.getFiltersConditions()
        if !filters.isEmpty {
            self.delegate?.filterViewControllerDidApply(self, filters: self.filters)
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func cancelAction() {
        self.dismiss(animated: true)
    }
    
    @IBAction func filterSwitchToggled(_ sender: UISwitch) {
        let viewToToggle: UIView?

        switch sender.tag {
        case 1: viewToToggle = self.amountFilterView
        case 2: viewToToggle = self.stateFilterView
        case 3: viewToToggle = self.dateFilterView
        case 4:
            self.dateTagsCollectionView.superview?.isHidden = sender.isOn
            viewToToggle = self.dateRangeFilterView
        default: viewToToggle = nil
        }

        viewToToggle?.isHidden = !sender.isOn
    }
    
    @IBAction func resetFilters() {
        self.delegate?.filterViewControllerDidApply(self, filters: FiltersModel.createEmptyModel())
        self.dismiss(animated: true)
    }
    
    // MARK: - private
    
    @objc private func donePressed() {
        guard let picker = self.datePicker,
              let textField = self.currentlyEditingTextField else { return }

        textField.text = DateFormatter.shared.string(from: picker.date)
        textField.resignFirstResponder()
    }
    
    private func configureTextFields() {
        [self.amountFromTextField, self.amountToTextField, self.statePercentTextField, self.dateFromTextField, self.dateToTextField].forEach { textField in
            textField.applyStandardStyle()
            textField.delegate = self
        }
        self.configureMenuForStateOptionButton()
    }
    
    private func configureMenuForStateOptionButton() {
        let menuClosure: (UIAction) -> () = { [weak self] (action: UIAction) in
            self?.optionButton.setTitle(action.title, for: .normal)
          }
        
        self.optionButton.menu = UIMenu(children: [
                  UIAction(title: "від", handler: menuClosure),
                  UIAction(title: "до", handler: menuClosure)
              ])
        self.optionButton.showsMenuAsPrimaryAction = true
    }
    
    private func configureCollectionViewWithTags(_ collectionView: UICollectionView, allowsMultipleSelection: Bool) {
        let nib = UINib(nibName: "TagButtonCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "TagButtonCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = allowsMultipleSelection
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    private func configureInputView(for textFields: [UITextField]) {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.maximumDate = Date()
        picker.locale = Locale(identifier: "uk_UA")
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(self.donePressed))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        self.datePicker = picker
        
        textFields.forEach { textField in
            textField.inputAccessoryView = toolbar
            textField.inputView = picker
        }
    }
    
    private func renameLabel(near switchButton: UISwitch, to title: String) {
        switchButton.superview?.subviews.forEach { view in
            if let label = view as? UILabel {
                label.text = title
            }
        }
    }
    
    private func setFiltersConditions() {
        if self.filters.isEmpty {
            self.resetButtonView.isHidden = true
            return
        } else {
            self.resetButtonView.isHidden = false
        }
        
        if let selectedPurposeTags = self.filters.purposeTags {
            selectedPurposeTags.forEach { tag in
                if let tagIndex = self.purposeTags.firstIndex(of: tag) {
                    let indexPath = IndexPath(item: tagIndex, section: 0)
                    self.purposeTagsCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                }
            }
        }
        
        if let amountFrom = self.filters.amountFrom, let amountTo = self.filters.amountTo {
            self.amountFilterSwitch.setOn(true, animated: false)
            self.filterSwitchToggled(self.amountFilterSwitch)
            self.amountFromTextField.text = String(Int(amountFrom))
            self.amountToTextField.text = String(Int(amountTo))
        }
        
        if let (comparisonOperator, percent) = self.filters.state {
            self.stateFilterSwitch.setOn(true, animated: false)
            self.filterSwitchToggled(self.stateFilterSwitch)
            self.optionButton.setTitle(comparisonOperator, for: .normal)
            self.statePercentTextField.text = String(percent)
        }
        
        if let dateTag = self.filters.dateTag {
            self.dateFilterSwitch.setOn(true, animated: false)
            self.filterSwitchToggled(self.dateFilterSwitch)
            if let tagIndex = self.dateTags.firstIndex(of: dateTag) {
                let indexPath = IndexPath(item: tagIndex, section: 0)
                self.dateTagsCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
        
        if let dateFrom = self.filters.dateFrom, let dateTo = self.filters.dateTo {
            self.dateFilterSwitch.setOn(true, animated: false)
            self.dateRangeFilterSwitch.setOn(true, animated: false)
            self.filterSwitchToggled(self.dateRangeFilterSwitch)
            self.dateFromTextField.text = DateFormatter.shared.string(from: dateFrom)
            self.dateToTextField.text = DateFormatter.shared.string(from: dateTo)
        }
    }
    
    private func getFiltersConditions() {
        self.filters = FiltersModel.createEmptyModel()
        
        if let selectedIndexPaths = self.purposeTagsCollectionView.indexPathsForSelectedItems {
            let selectedTags: [String] = selectedIndexPaths.map {  self.purposeTags[$0.item] }
            if selectedTags != [] {
                self.filters = self.filters.addPurposeTags(selectedTags)
            }
        }
        
        if let (amountFrom, amountTo) = self.checkAmountFilters() {
            self.filters = self.filters.addAmountBounds(from: amountFrom, to: amountTo)
        }
        
        if let (comparisonOperator, percent) = self.checkStateFilter() {
            self.filters = self.filters.addState(comparisonOperator, percent)
        }
        
        if self.dateFilterSwitch.isOn {
            if self.dateRangeFilterSwitch.isOn {
                if let (dateFrom, dateTo) = self.checkDateRangeFilters() {
                    self.filters = self.filters.addDateBounds(from: dateFrom, to: dateTo)
                }
            } else {
                if let selectedIndexPath = self.dateTagsCollectionView.indexPathsForSelectedItems?.first {
                    let selectedTag = self.dateTags[selectedIndexPath.item]
                    self.filters = self.filters.addDateTag(selectedTag)
                }
            }
        }
    }
    
    // MARK: - checks
    
    private func checkAmountFilters() -> (Double, Double)? {
        guard self.amountFilterSwitch.isOn else { return nil }
        
        if let amountFrom = self.checkDoubleFields(self.amountFromTextField),
           let amountTo = self.checkDoubleFields(self.amountToTextField, withZeroCheck: true) {
            if amountFrom < amountTo {
                self.amountErrorLabel.text = ""
                return (amountFrom, amountTo)
            } else {
                self.amountErrorLabel.text = "Значення поля \"до\" має бути більшим за значення поля \"від\""
            }
        }
        return nil
    }
    
    private func checkStateFilter() -> (String, Int)? {
        guard self.stateFilterSwitch.isOn else { return nil }
        
        if let percentValue = self.checkDoubleFields(self.statePercentTextField),
           let selectedOption = self.optionButton.currentTitle {
            if selectedOption == "до" && percentValue == 0 {
                self.stateErrorLabel.text = "Моживо, ви мали на увазі \"від\"?"
            }  else {
                self.stateErrorLabel.text = ""
                return (selectedOption, Int(percentValue))
            }
        }
        return nil
    }
    
    private func checkDateRangeFilters() -> (Date, Date)? {
        if let dateFrom = self.checkDateFields(self.dateFromTextField),
           let dateTo = self.checkDateFields(self.dateToTextField) {
            if dateFrom < dateTo {
                self.dateErrorLabel.text = ""
                return (dateFrom, dateTo)
            } else {
                self.dateErrorLabel.text = "Значення дати \"до\" має бути більшим за значення дати \"від\""
            }
        }
        return nil
    }
    
    private func checkDoubleFields(_ textField: UITextField, withZeroCheck: Bool = false) -> Double? {
        if textField.isNotEmpty, let value = Double(textField.text?.replacingOccurrences(of: " ", with: "") ?? "0"), !withZeroCheck || value > 0 {
            textField.layer.borderColor = UIColor.gray.cgColor
            return value
        }
        textField.layer.borderColor = UIColor.red.cgColor
        return nil
    }
    
    private func checkDateFields(_ textField: UITextField) -> Date? {
        if textField.isNotEmpty, let value = textField.text, let date = DateFormatter.shared.date(from: value) {
            textField.layer.borderColor = UIColor.gray.cgColor
            return date
        }
        textField.layer.borderColor = UIColor.red.cgColor
        return nil
    }
    
    private func formatAmountValue(_ textField: UITextField, _ newText: String) -> String {
        let reverseValue = newText.replacingOccurrences(of: " ", with: "").reversed()
        var formattedValue = ""
        for (index, char) in reverseValue.enumerated() {
            if index != 0 && index % 3 == 0 {
                formattedValue.append(" ")
            }
            formattedValue.append(char)
        }
        return String(formattedValue.reversed())
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.currentlyEditingTextField = textField
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        switch textField {
        case self.amountFromTextField:
            self.amountFromTextField.text = self.formatAmountValue(self.amountFromTextField, newText)
            return false
            
        case self.amountToTextField:
            self.amountToTextField.text = self.formatAmountValue(self.amountToTextField, newText)
            return false
            
        case self.statePercentTextField:
            if newText.count > 2 {
                return false
            }
            
        case self.dateFromTextField: return true
        case self.dateToTextField: return true
        default:
            return false
        }
        
        return true
    }
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.purposeTagsCollectionView {
            return self.purposeTags.count
        } else {
            return self.dateTags.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let tagsArray = collectionView == self.purposeTagsCollectionView ? self.purposeTags : self.dateTags
        let cell = (collectionView.dequeueReusableCell(withReuseIdentifier: "TagButtonCell", for: indexPath) as? TagButtonCollectionViewCell)
            .flatMap {
                $0.configureWithTitle(tagsArray[indexPath.item])
                return $0
            }
        return cell ?? UICollectionViewCell()
    }
}

protocol FilterViewControllerDelegate: AnyObject {
    func filterViewControllerDidApply(_ controller: FilterViewController, filters: FiltersModel)
}
