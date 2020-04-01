/*
 * Copyright © 2019, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

import UIKit

class CustomActionVC: UIViewController, MCEActionProtocol {
    var _interfaceState: Data? = nil
    
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var valueField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    
    var registeredTypes = [String]()
    let keyboardToolbar = UIToolbar()
    
    let colors = (
        error: UIColor(red: 0.5, green: 0, blue: 0, alpha: 1),
        success: UIColor(red: 0, green: 0.5, blue: 0, alpha: 1),
        warning: UIColor(red: 0.574, green: 0.566, blue: 0, alpha: 1)
    )
        
    // This method simulates a custom action registering to receive push actions
    @IBAction func registerCustomAction(_ sender: Any) {
        guard let string = typeField.text else {
            return
        }
        
        registerCustomAction(string: string)
    }
    
    func registerCustomAction(string: String) {
        registeredTypes.append(string)
        var customActions = Set( UserDefaults.standard.stringArray(forKey: "customActions") ?? [String]() )
        customActions.insert(string)
        UserDefaults.standard.set(Array(customActions), forKey: "customActions")
        
        statusLabel.text = "Registering Custom Action: \(string)"
        statusLabel.textColor = colors.success
        MCEActionRegistry.shared.registerTarget(self, with: #selector(self.receiveCustomAction(action:)), forAction: string)
    }
    
    // This method shows how to unregister a custom action
    @IBAction func unregisterCustomAction(_ sender: Any) {
        guard let type = typeField.text else {
            return
        }
        registeredTypes.removeAll(where: { (registeredType) -> Bool in
            return registeredType == type
        })
        statusLabel.textColor = colors.success
        statusLabel.text = "Unregistered Action: \(type)"
        MCEActionRegistry.shared.unregisterAction(type)
    }
    
    // This method simulates a user clicking on a push message with a custom action
    @IBAction func sendCustomAction(_ sender: Any) {
        guard let type = typeField.text, let value = valueField.text else {
            return
        }
        let action = ["type": type, "value": value]
        let payload = ["notification-action": action]
        statusLabel.textColor = colors.success
        statusLabel.text = "Sending Custom Action: \(action)"
        MCEActionRegistry.shared.performAction(action, forPayload: payload, source: "internal", attributes: nil, userText: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        keyboardToolbar.barStyle = .default
        keyboardToolbar.isTranslucent = true
        keyboardToolbar.tintColor = nil
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneClicked))
        doneButton.accessibilityIdentifier = "doneButton"
        keyboardToolbar.items = [doneButton]
        
        NotificationCenter.default.addObserver(forName: MCENotificationName.customPushNotYetRegistered.rawValue, object: nil, queue: .main) { (note) in
            guard let action = note.userInfo?["action"] as? [String:Any] else {
                return
            }
            self.statusLabel.textColor = self.colors.warning
            self.statusLabel.text = "Previously Registered Custom Action Received: \(action)"
        }
        
        NotificationCenter.default.addObserver(forName: MCENotificationName.customPushNotRegistered.rawValue, object: nil, queue: .main) { (note) in
            guard let action = note.userInfo?["action"] as? [String:Any] else {
                return
            }
            self.statusLabel.textColor = self.colors.error
            self.statusLabel.text = "Unregistered Custom Action Received: \(action)"
        }
        
        NotificationCenter.default.addObserver(forName: UIWindow.keyboardWillChangeFrameNotification, object: nil, queue: .main) { (note) in
            if let keyboardHeightLayoutConstraint = self.keyboardHeightLayoutConstraint, let userInfo = note.userInfo,
                let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
                let optionsInteger = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
                let options = UIView.AnimationOptions(rawValue: optionsInteger)
                
                if frame.origin.y >= UIScreen.main.bounds.size.height {
                    keyboardHeightLayoutConstraint.constant = 0
                } else {
                    keyboardHeightLayoutConstraint.constant = frame.size.height
                }
                
                UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        for type in registeredTypes {
            MCEActionRegistry.shared.unregisterAction(type)
        }
        registeredTypes.removeAll()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTheme()
    }
    
    @objc func doneClicked() {
        typeField.resignFirstResponder()
        valueField.resignFirstResponder()
    }
    

    // This method simulates how custom actions receive push actions
    @objc func receiveCustomAction(action: NSDictionary) {
        DispatchQueue.main.async {
            self.statusLabel.text = "Received Custom Action: \(action)"
            self.statusLabel.textColor = self.colors.success
        }
    }
    
    func updateTheme() {
        typeField.textColor = .foreground
        valueField.textColor = .foreground
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateTheme()
    }
}

extension CustomActionVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        guard reason == .committed else {
            return
        }
        UserDefaults.standard.set(["interfaceState": interfaceState], forKey: String(describing: type(of: self)))
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.inputAccessoryView = keyboardToolbar
        keyboardToolbar.sizeToFit()
    }
}

// Generic State Restoration
extension CustomActionVC: RestorableVC {
    struct InterfaceState: Codable {
        let typeField: String
        let valueField: String
        let statusText: String
        let statusColor: Data
        var editingField: TextField? = nil
        var editingValue: String? = nil
        var registeredTypes: [String]
    }

    enum TextField: String, Codable {
        case typeField
        case valueField
    }
    
    var interfaceState: Data? {
        get {
            var interfaceState = InterfaceState(
                typeField: typeField.text ?? "",
                valueField: valueField.text ?? "",
                statusText: self.statusLabel.text ?? "No status yet",
                statusColor: self.statusLabel.textColor.data,
                registeredTypes: registeredTypes
            )

            if typeField.isFirstResponder {
                interfaceState.editingField = .typeField
                interfaceState.editingValue = typeField.text
            } else if valueField.isFirstResponder {
                interfaceState.editingField = .valueField
                interfaceState.editingValue = valueField.text
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
            return
        }
        
        let interfaceState: InterfaceState
        do {
            interfaceState = try PropertyListDecoder().decode(InterfaceState.self, from: data)
        } catch {
            print("Could not decode interface state \(error)")
            return
        }

        for string in interfaceState.registeredTypes {
            registerCustomAction(string: string)
        }

        typeField.text = interfaceState.typeField
        valueField.text = interfaceState.valueField
        
        statusLabel.text = interfaceState.statusText
        statusLabel.textColor = UIColor.from(data: interfaceState.statusColor) ?? UIColor.disabled
        
        if let editingField = interfaceState.editingField, let value = interfaceState.editingValue {
            switch editingField {
            case .typeField:
                typeField.text = value
                typeField.becomeFirstResponder()
            case .valueField:
                valueField.text = value
                valueField.becomeFirstResponder()
            }
        }
        
        _interfaceState = nil
    }
    
}

// State restoration iOS ≤12
extension CustomActionVC {
    
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
extension CustomActionVC {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        restoreInterfaceStateIfAvailable()
    }
}
