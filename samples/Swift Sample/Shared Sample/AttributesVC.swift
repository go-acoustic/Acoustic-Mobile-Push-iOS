/*
 * Copyright © 2011, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

import AcousticMobilePush
import UIKit

enum ValueTypes: Int, CaseIterable {
    case date
    case string
    case bool
    case number
}

class AttributesVC: UIViewController {
    var _interfaceState: Data? = nil
    
    enum OperationTypes: Int {
        case update
        case delete
    }
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var valueTypeControl: UISegmentedControl!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var boolSwitch: UISwitch!
    @IBOutlet weak var operationTypeControl: UISegmentedControl!
    @IBOutlet weak var addQueueButton: UIButton!
    @IBOutlet weak var booleanView: UIView!
    
    var datePicker = UIDatePicker()
    var dateFormatter = DateFormatter()
    var keyboardToolbar = UIToolbar()
    var numberFormatter = NumberFormatter()
    
    @objc func updateDate() {
        valueTextField.text = dateFormatter.string(from: datePicker.date)
    }

    @IBAction func addQueueTap(sender: Any) {
        guard Thread.isMainThread else {
            DispatchQueue.main.sync {
                addQueueTap(sender: sender)
            }
            return
        }
        
        valueTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        
        guard let name = nameTextField.text, let operation = OperationTypes(rawValue: operationTypeControl.selectedSegmentIndex), let valueType = ValueTypes(rawValue: valueTypeControl.selectedSegmentIndex) else {
            return
        }
        
        switch operation {
        case .update:
            switch valueType {
            case .bool:
                let boolValue = boolSwitch.isOn
                updateStatus(text: "Queued User Attribute Update\n\(name)=\(boolValue)", color: .warning)
                MCEAttributesQueueManager.shared.updateUserAttributes([name:boolValue])
                break
            case .date:
                guard let text = valueTextField.text, let dateValue = dateFormatter.date(from: text) else {
                    return
                }
                updateStatus(text: "Queued User Attribute Update\n\(name)=\(dateValue)", color: .warning)
                MCEAttributesQueueManager.shared.updateUserAttributes([name:dateValue])
                break
            case .number:
                guard let text = valueTextField.text else {
                    return
                }
                let numberValue = (text as NSString).doubleValue
                updateStatus(text: "Queued User Attribute Update\n\(name)=\(numberValue)", color: .warning)
                MCEAttributesQueueManager.shared.updateUserAttributes([name:numberValue])
                break
            case .string:
                guard let text = valueTextField.text else {
                    return
                }
                updateStatus(text: "Queued User Attribute Update\n\(name)=\(text)", color: .warning)
                MCEAttributesQueueManager.shared.updateUserAttributes([name:text])
                break
            }
            break
        case .delete:
            updateStatus(text: "Queued User Attribute Removal\nName \"\(name)\"", color: .warning)
            MCEAttributesQueueManager.shared.deleteUserAttributes([name])
            break
        }
    }
    
    @IBAction func valueTypeTap(sender: Any) {
        if #available(iOS 13.0, *) {
            userActivity?.needsSave = true
        }

        UserDefaults.standard.set(interfaceState, forKey: String(describing: type(of: self)))
        updateValueControls()
    }
    
    @IBAction func operationTypeTap(sender: Any) {
        if #available(iOS 13.0, *) {
            userActivity?.needsSave = true
        }
        UserDefaults.standard.set(interfaceState, forKey: String(describing: type(of: self)))
        updateValueControls()
    }
    
    @IBAction func boolValueChanged(sender: Any) {
        if #available(iOS 13.0, *) {
            userActivity?.needsSave = true
        }
        UserDefaults.standard.set(interfaceState, forKey: String(describing: type(of: self)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        numberFormatter.numberStyle = .decimal
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        datePicker.datePickerMode = .dateAndTime
        datePicker.accessibilityIdentifier = "datePicker"
        datePicker.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        keyboardToolbar.barStyle = .default
        keyboardToolbar.isTranslucent = true
        keyboardToolbar.tintColor = nil
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneClicked))
        doneButton.accessibilityIdentifier = "doneButton"
        keyboardToolbar.items = [doneButton]
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserAttributesSuccess), name: MCENotificationName.UpdateUserAttributesSuccess.rawValue, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserAttributesError), name: MCENotificationName.UpdateUserAttributesError.rawValue, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deleteUserAttributesError), name: MCENotificationName.DeleteUserAttributesError.rawValue, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deleteUserAttributesSuccess), name: MCENotificationName.DeleteUserAttributesSuccess.rawValue, object: nil)

        datePicker.addTarget(self, action: #selector(updateDate), for: .valueChanged)
    }
    
    @objc func doneClicked(sender: Any) {
        if valueTextField.isFirstResponder {
            valueTextField.resignFirstResponder()
        } else if nameTextField.isFirstResponder {
            nameTextField.resignFirstResponder()
        }
        
        if #available(iOS 13.0, *) {
            userActivity?.needsSave = true
        }

        UserDefaults.standard.set(interfaceState, forKey: String(describing: type(of: self)))
    }
    
    @objc func deleteUserAttributesError(note: NSNotification) {
        guard Thread.isMainThread else {
            DispatchQueue.main.sync {
                deleteUserAttributesError(note: note)
            }
            return
        }
        
        guard let userInfo = note.userInfo, let error = userInfo["error"] as? Error, let keys = userInfo["keys"] as? [String] else {
            return
        }
        updateStatus(text: "Couldn't Delete User Attributes Named\n\(keys.joined(separator: "\n"))\nbecause \(error.localizedDescription)", color: .failure)
    }
    
    @objc func deleteUserAttributesSuccess(note: NSNotification) {
        guard Thread.isMainThread else {
            DispatchQueue.main.sync {
                deleteUserAttributesSuccess(note: note)
            }
            return
        }
        
        guard let userInfo = note.userInfo, let keys = userInfo["keys"] as? [String] else {
            return
        }
        updateStatus(text: "Deleted User Attributes Named\n\(keys.joined(separator: "\n"))", color: .success)
    }
    
    @objc func updateUserAttributesError(note: NSNotification) {
        guard Thread.isMainThread else {
            DispatchQueue.main.sync {
                updateUserAttributesError(note: note)
            }
            return
        }
        
        guard let userInfo = note.userInfo, let attributes = userInfo["attributes"] as? [String:Any], let error = userInfo["error"] as? Error else {
            return
        }
        var keyvalues = [String]()
        
        for (key, value) in attributes {
            keyvalues.append("\(key)=\(value)")
        }
        
        updateStatus(text: "Couldn't Update User Attributes\n\(keyvalues.joined(separator: "\n"))\nbecause \(error.localizedDescription)", color: .failure)
    }
    
    @objc func updateUserAttributesSuccess(note: NSNotification) {
        guard Thread.isMainThread else {
            DispatchQueue.main.sync {
                updateUserAttributesSuccess(note: note)
            }
            return
        }
        
        guard let userInfo = note.userInfo, let attributes = userInfo["attributes"] as? [String:Any] else {
            return
        }
        
        var keyvalues = [String]()
        
        for (key, value) in attributes {
            keyvalues.append("\(key)=\(value)")
        }
        
        updateStatus(text: "Updated User Attributes\n\(keyvalues.joined(separator: "\n"))", color: .success)
    }
    
    func updateStatus(text: String, color: UIColor) {
        DispatchQueue.main.async {
            self.statusLabel.text = text
            self.statusLabel.textColor = color
        }
    }
    
    func updateTheme() {
        nameTextField.textColor = .foreground
        valueTextField.textColor = .foreground
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateTheme()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        valueTypeControl.accessibilityIdentifier = "attributeType"
        operationTypeControl.accessibilityIdentifier = "attributeOperation"
        updateValueControls()
        updateTheme()
    }
    
    func hideAllValueControls() {
        valueTextField.isEnabled = false
        valueTextField.alpha = 0.5
        valueTypeControl.isEnabled = false
        boolSwitch.isEnabled = false
        boolSwitch.alpha = 0
        booleanView.alpha = 0
    }
    
    func showTextValueControls() {
        valueTextField.resignFirstResponder()
        valueTextField.isEnabled = true
        valueTextField.alpha = 1
        valueTypeControl.isEnabled = true
        boolSwitch.isEnabled = false
        boolSwitch.alpha = 0
        booleanView.alpha = 0
    }
    
    func showBoolValueControls() {
        valueTextField.isEnabled = false
        valueTextField.alpha = 0
        valueTypeControl.isEnabled = true
        boolSwitch.isEnabled = true
        boolSwitch.alpha = 1
        booleanView.alpha = 1
    }
    
    func updateValueControls() {
        guard let operation = OperationTypes(rawValue: operationTypeControl.selectedSegmentIndex), let valueType = ValueTypes(rawValue: valueTypeControl.selectedSegmentIndex) else {
            return
        }
        
        switch operation {
        case .update:
            switch valueType {
            case .bool:
                showBoolValueControls()
                break
            case .date:
                showTextValueControls()
                valueTextField.text = dateFormatter.string(from: datePicker.date)
                break
            case .string:
                showTextValueControls()
                valueTextField.keyboardType = .default
                break
            case .number:
                valueTextField.keyboardType = .decimalPad
                showTextValueControls()
                
                if let text = valueTextField.text, CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: text)) {
                    
                } else {
                    valueTextField.text = "0"
                }

                break
            }
            break
        case .delete:
            hideAllValueControls()
            break
        }
    }
}

extension AttributesVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if #available(iOS 13.0, *) {
            userActivity?.needsSave = true
        }

        UserDefaults.standard.set(interfaceState, forKey: String(describing: type(of: self)))
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == valueTextField {
            if valueTypeControl.selectedSegmentIndex == ValueTypes.date.rawValue {
                valueTextField.inputView = datePicker
            } else {
                valueTextField.inputView = nil
            }
        }
        textField.inputAccessoryView = keyboardToolbar
        keyboardToolbar.sizeToFit()
    }
}

// State restoration iOS ≤12
extension AttributesVC {
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(interfaceState, forKey: "interfaceState")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        if let interfaceState = coder.decodeObject(forKey: "interfaceState") as? Data {
            self.interfaceState = interfaceState
        }
    }

}

// State Restoration and Multiple Window Support iOS ≥13
extension AttributesVC {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        restoreInterfaceStateIfAvailable()
    }
}

// Generic State Restoration
extension AttributesVC: RestorableVC {
    enum TextField: String, Codable {
        case valueTextField
        case nameTextField
    }
    struct InterfaceState: Codable {
        let attributeValue: String?
        let attributeName: String?
        let attributeOperation: Int
        let attributeValueType: Int
        let boolSwitch: Bool
        let datePicker: Date
        let statusText: String?
        let statusColor: Data
        var editingField: TextField? = nil
        var editingValue: String? = nil
    }
        
    var interfaceState: Data? {
        get {
            var interfaceState = InterfaceState(
                attributeValue: valueTextField.text,
                attributeName: nameTextField.text,
                attributeOperation: operationTypeControl.selectedSegmentIndex,
                attributeValueType: valueTypeControl.selectedSegmentIndex,
                boolSwitch: boolSwitch.isOn,
                datePicker: datePicker.date,
                statusText: self.statusLabel.text,
                statusColor: self.statusLabel.textColor.data
            )
            
            if valueTextField.isFirstResponder {
                interfaceState.editingField = .valueTextField
                interfaceState.editingValue = valueTextField.text
            } else if nameTextField.isFirstResponder {
                interfaceState.editingField = .nameTextField
                interfaceState.editingValue = nameTextField.text
            }
            
            do {
                return try PropertyListEncoder().encode(interfaceState)
            } catch {
                print("Could not encode interface state \(error)")
                return nil
            }
        } set {
            _interfaceState = newValue
        }
    }

    func restoreInterfaceStateIfAvailable() {
        guard let data = _interfaceState else {
            updateValueControls()
            return
        }
        
        let interfaceState: InterfaceState
        do {
            interfaceState = try PropertyListDecoder().decode(InterfaceState.self, from: data)
        } catch {
            print("Could not decode interface state \(error)")
            return
        }

        valueTextField.text = interfaceState.attributeValue
        nameTextField.text = interfaceState.attributeName
        datePicker.date = interfaceState.datePicker
        valueTypeControl.selectedSegmentIndex = interfaceState.attributeValueType
        operationTypeControl.selectedSegmentIndex = interfaceState.attributeOperation
        boolSwitch.isOn = interfaceState.boolSwitch
        
        statusLabel.text = interfaceState.statusText
        statusLabel.textColor = UIColor.from(data: interfaceState.statusColor) ?? UIColor.disabled
        
        updateValueControls()
        if let editingField = interfaceState.editingField, let value = interfaceState.editingValue {
            switch editingField {
            case .valueTextField:
                valueTextField.text = value
                valueTextField.becomeFirstResponder()
            case .nameTextField:
                nameTextField.text = value
                nameTextField.becomeFirstResponder()
            }
        }
        
        _interfaceState = nil
    }
}
