/*
 * Copyright © 2018, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

import UIKit
import AcousticMobilePush

class EventVC: UIViewController {
    var _interfaceState: Data? = nil
        
    enum EventType: Int {
        case CustomEvent
        case SimulateEvent
    }
    
    enum LocationEvents: String, CaseIterable {
        case disabled
        case enabled
        case enter
        case exit
    }
    
    enum ActionEvents: String, CaseIterable {
        case urlClicked
        case appOpened
        case phoneNumberClicked
        case inboxMessageOpened
    }
    
    enum ApplicationEvents: String, CaseIterable {
        case sessionStarted
        case sessionEnded
        case uiPushEnabled
        case uiPushDisabled
    }
    
    enum SimulatedEvents: Int {
        case AppEvent
        case ActionEvent
        case InboxEvent
        case GeofenceEvent
        case iBeaconEvent
    }
    
    @IBOutlet weak var customEvent: UISegmentedControl!
    @IBOutlet weak var simulateEvent: UISegmentedControl!
    @IBOutlet weak var typeSwitch: UISegmentedControl!
    @IBOutlet weak var nameSwitch: UISegmentedControl!
    @IBOutlet weak var attributionField: UITextField!
    @IBOutlet weak var mailingIdField: UITextField!
    @IBOutlet weak var attributeValueField: UITextField!
    @IBOutlet weak var attributeNameField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var booleanContainer: UIView!
    @IBOutlet weak var booleanSwitch: UISwitch!
    @IBOutlet weak var attributeTypeSwitch: UISegmentedControl!
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    @IBOutlet weak var eventStatus: UILabel!
    
    var datePicker = UIDatePicker()
    var dateFormatter = DateFormatter()
    var keyboardToolbar = UIToolbar()
    var numberFormatter = NumberFormatter()
    
    func updateTheme() {
        attributionField.textColor = .foreground
        mailingIdField.textColor = .foreground
        attributeValueField.textColor = .foreground
        attributeNameField.textColor = .foreground
        nameField.textColor = .foreground
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateTheme()
    }

    @IBAction func updateTypeSelections(_ sender: Any) {
        if #available(iOS 13.0, *) {
            userActivity?.needsSave = true
        }

        UserDefaults.standard.set(interfaceState, forKey: String(describing: type(of: self)))

        attributeTypeSwitch.isEnabled = true
        attributeNameField.isEnabled = true
        attributeValueField.isEnabled = true
        booleanSwitch.isEnabled = true
        
        doneClicked()
        for i in ValueTypes.allCases {
            attributeTypeSwitch.setEnabled(true, forSegmentAt: i.rawValue)
        }
        
        switch(customEvent.selectedSegmentIndex) {
        case EventType.CustomEvent.rawValue:
            nameSwitch.isHidden = true
            nameField.isHidden = false
            simulateEvent.isEnabled = false
            updateType(segments: ["custom"])
        case EventType.SimulateEvent.rawValue:
            
            nameField.isHidden = true
            nameSwitch.isHidden = false
            simulateEvent.isEnabled = true
            if let simulatedEvent = SimulatedEvents(rawValue: simulateEvent.selectedSegmentIndex) {
                switch simulatedEvent {
                case .AppEvent:
                    updateType(segments: ["application"])
                    updateName(segments: ApplicationEvents.allCases.map({event in event.rawValue}))
                    switch Array(ApplicationEvents.allCases)[nameSwitch.selectedSegmentIndex] {
                    case .sessionStarted:
                        allowNoAttributes()
                    case .sessionEnded:
                        attributeNameField.text = "sessionLength"
                        onlyAllowNumberAttributes()
                    case .uiPushEnabled, .uiPushDisabled:
                        allowNoAttributes()
                    }
                    
                    
                case .ActionEvent:
                    updateType(segments: [SimpleNotificationSource, InboxSource, InAppSource])
                    updateName(segments: ActionEvents.allCases.map({event in event.rawValue}))
                    switch Array(ActionEvents.allCases)[nameSwitch.selectedSegmentIndex] {
                    case .urlClicked:
                        onlyAllowStringAttributes()
                        self.attributeNameField.text = "url"
                    case .appOpened:
                        allowNoAttributes()
                    case .phoneNumberClicked:
                        onlyAllowNumberAttributes()
                        attributeNameField.text = "phoneNumber"
                    case .inboxMessageOpened:
                        onlyAllowStringAttributes()
                        attributeNameField.text = "richContentId"
                    }
                case .InboxEvent:
                    updateType(segments: ["inbox"])
                    updateName(segments: ["messageOpened"])
                    onlyAllowStringAttributes()
                    attributeNameField.text = "inboxMessageId"
                case .GeofenceEvent:
                    updateType(segments: ["geofence"])
                    updateName(segments: LocationEvents.allCases.map({event in event.rawValue}))
                case .iBeaconEvent:
                    updateType(segments: ["ibeacon"])
                    updateName(segments: LocationEvents.allCases.map({event in event.rawValue}))
                }
                
                if simulatedEvent == .GeofenceEvent || simulatedEvent == .iBeaconEvent {
                    switch Array(LocationEvents.allCases)[nameSwitch.selectedSegmentIndex] {
                    case .disabled:
                        onlyAllowStringAttributes()
                        attributeNameField.text = "reason"
                        attributeValueField.text = "not_enabled"
                    case .enabled:
                        allowNoAttributes()
                    case .enter, .exit:
                        onlyAllowStringAttributes()
                        attributeNameField.text = "locationId"
                    }
                }
            }
        default:
            break
        }
        
        if let valueType = ValueTypes(rawValue: attributeTypeSwitch.selectedSegmentIndex) {
            switch valueType {
            case .date:
                attributeValueField.isHidden = false
                booleanContainer.isHidden = true
                if dateFormatter.date(from: attributeValueField.text!) == nil {
                    attributeValueField.text = ""
                }
            case .string:
                attributeValueField.keyboardType = .default
                attributeValueField.isHidden = false
                booleanContainer.isHidden = true
            case .number:
                attributeValueField.keyboardType = .decimalPad
                attributeValueField.isHidden = false
                booleanContainer.isHidden = true
                if numberFormatter.number(from: attributeValueField.text!) == nil {
                    attributeValueField.text = ""
                }
            case .bool:
                attributeValueField.isHidden = true
                booleanContainer.isHidden = false
            }
        }
        
        view.layoutSubviews()
    }
    
    func onlyAllowNumberAttributes() {
        attributeTypeSwitch.isEnabled = false
        booleanSwitch.isEnabled = false
        allowOnlyAttributeType(ValueTypes.number)
        attributeTypeSwitch.selectedSegmentIndex = ValueTypes.number.rawValue
    }
    
    func allowOnlyAttributeType(_ allowed: ValueTypes?) {
        for type in ValueTypes.allCases {
            if type == allowed {
                attributeTypeSwitch.setEnabled(true, forSegmentAt: type.rawValue)
            } else {
                attributeTypeSwitch.setEnabled(false, forSegmentAt: type.rawValue)
            }
        }
    }
    
    func allowNoAttributes() {
        attributeNameField.text = ""
        attributeValueField.text = ""
        allowOnlyAttributeType(nil)
        attributeNameField.isEnabled = false
        attributeTypeSwitch.isEnabled = false
        attributeValueField.isEnabled = false
        booleanSwitch.isEnabled = false
    }
    
    func onlyAllowStringAttributes() {
        attributeTypeSwitch.isEnabled = false
        booleanSwitch.isEnabled = false
        allowOnlyAttributeType(ValueTypes.string)
        attributeTypeSwitch.selectedSegmentIndex = ValueTypes.string.rawValue
    }
    
    func updateName(segments: [String]) {
        update(control: nameSwitch, segments: segments)
    }
    
    func updateType(segments: [String]) {
        update(control: typeSwitch, segments: segments)
    }
    
    func resize(control: UISegmentedControl, count: Int) {
        while control.numberOfSegments > count {
            control.removeSegment(at: 0, animated: false)
        }
        while control.numberOfSegments < count {
            control.insertSegment(withTitle: nil, at: 0, animated: false)
        }
    }
    
    func update(control: UISegmentedControl, segments: [String]) {
        resize(control: control, count: segments.count)
        for (index, segment) in segments.enumerated() {
            control.setTitle(segment, forSegmentAt: index)
        }
        
        var selected = control.selectedSegmentIndex
        if selected > segments.count || selected < 0 {
            selected = 0
        }
        DispatchQueue.main.async {
            control.selectedSegmentIndex = UISegmentedControl.noSegment
            
            DispatchQueue.main.async {
                control.selectedSegmentIndex = selected
            }
        }
    }
    
    func checkSegmentedControls() {
        for segmentedControl in [customEvent, simulateEvent, typeSwitch, nameSwitch, attributeTypeSwitch] {
            if let segmentedControl = segmentedControl {
                if segmentedControl.selectedSegmentIndex > segmentedControl.numberOfSegments || segmentedControl.selectedSegmentIndex < 0 {
                    segmentedControl.selectedSegmentIndex = 0
                }
            }
        }
    }
    
    @IBAction func sendEvent(_ sender: Any) {
        var type: String? = nil
        var name: String? = nil
        
        checkSegmentedControls()
        
        let attribution = attributionField.text!.count > 0 ? attributionField.text : nil
        let mailingId = mailingIdField.text!.count > 0 ? mailingIdField.text : nil
        
        doneClicked()
        if let eventType = EventType(rawValue: customEvent.selectedSegmentIndex) {
            switch eventType {
            case .CustomEvent:
                type = "custom"
                name = nameField.text!.count > 0 ? nameField.text : nil
            case .SimulateEvent:
                if typeSwitch.selectedSegmentIndex != UISegmentedControl.noSegment {
                    type = typeSwitch.titleForSegment(at: typeSwitch.selectedSegmentIndex)
                }
                if nameSwitch.selectedSegmentIndex != UISegmentedControl.noSegment {
                    name = nameSwitch.titleForSegment(at: nameSwitch.selectedSegmentIndex)
                }
            }
        }
        
        var attributes: [String: Any]? = nil
        let attributeValue = attributeValueField.text!
        let attributeName = attributeNameField.text!
        if attributeName.count > 0 {
            switch Array(ValueTypes.allCases)[attributeTypeSwitch.selectedSegmentIndex] {
            case .date:
                if let date = dateFormatter.date(from: attributeValue) {
                    attributes = [attributeName: date]
                }
            case .string:
                if attributeValue.count > 0 {
                    attributes = [attributeName: attributeValue]
                }
            case .number:
                if let number = numberFormatter.number(from: attributeValue) {
                    attributes = [attributeName: number]
                }
            case .bool:
                attributes = [attributeName: booleanSwitch.isOn]
            }
        }
        
        if let name = name, let type = type {
            let event = MCEEvent(name: name, type: type, timestamp: nil, attributes: attributes, attribution: attribution, mailingId: mailingId)
            MCEEventService.shared.add(event, immediate: true)
            DispatchQueue.main.async {
                self.updateStatus(text: "Queued Event with name: \(name), type: \(type)", color: .warning)
            }
        }
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendEventSuccess(note:)), name: MCENotificationName.eventSuccess.rawValue, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendEventFailure(note:)), name: MCENotificationName.eventFailure.rawValue, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardNotification(note:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardNotification(note: Notification) {
        if let keyboardHeightLayoutConstraint = keyboardHeightLayoutConstraint, let userInfo = note.userInfo,
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
    
    @objc func doneClicked() {
        if nameField.isFirstResponder {
            nameField.resignFirstResponder()
        } else if attributionField.isFirstResponder {
            attributionField.resignFirstResponder()
        } else if mailingIdField.isFirstResponder {
            mailingIdField.resignFirstResponder()
        } else if attributeNameField.isFirstResponder {
            attributeNameField.resignFirstResponder()
        } else if attributeValueField.isFirstResponder {
            if attributeTypeSwitch.selectedSegmentIndex == ValueTypes.date.rawValue {
                attributeValueField.text = dateFormatter.string(from: datePicker.date)
            }
            attributeValueField.resignFirstResponder()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateTheme()
        customEvent.accessibilityIdentifier = "customEvent"
        simulateEvent.accessibilityIdentifier = "simulateEvent"
        typeSwitch.accessibilityIdentifier = "typeSwitch"
        attributeTypeSwitch.accessibilityIdentifier = "attributeTypeSwitch"
        nameSwitch.accessibilityIdentifier = "nameSwitch"
    }
    

    @objc func sendEventSuccess(note: Notification) {
        if let userInfo = note.userInfo, let rawEvents = userInfo["events"], let events = rawEvents as? [MCEEvent] {
            var eventStrings = [String]()
            for event in events {
                if let name = event.name, let type = event.type {
                    eventStrings.append("name: \(name), type: \(type)")
                }
            }
            DispatchQueue.main.async {
                self.updateStatus(text: "Sent events: \( eventStrings.joined(separator: ",") )", color: .success)
            }
        }
    }
    
    @objc func sendEventFailure(note: Notification) {
        if let userInfo = note.userInfo, let rawError = userInfo["error"], let error = rawError as? Error, let rawEvents = userInfo["events"], let events = rawEvents as? [MCEEvent] {
            var eventStrings = [String]()
            for event in events {
                if let name = event.name, let type = event.type {
                    eventStrings.append("name: \(name), type: \(type)")
                }
            }
            DispatchQueue.main.async {
                self.updateStatus(text: "Couldn't send events: \( eventStrings.joined(separator: ",") ), because: \( error.localizedDescription )", color: .failure)
            }
        }
    }
    
    func updateStatus(text: String, color: UIColor) {
        self.eventStatus.text = text
        self.eventStatus.textColor = color
    }
    
}

extension EventVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == attributeValueField {
            if attributeTypeSwitch.selectedSegmentIndex == ValueTypes.date.rawValue {
                attributeValueField.inputView = datePicker
            } else {
                attributeValueField.inputView = nil
            }
        }
        textField.inputAccessoryView = keyboardToolbar
        keyboardToolbar.sizeToFit()
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        guard reason == .committed else {
            return
        }
        UserDefaults.standard.set(interfaceState, forKey: String(describing: type(of: self)))
    }
}

// Generic State Restoration
extension EventVC: RestorableVC {
    
    enum TextField: String, Codable {
        case attributionField
        case mailingIdField
        case attributeValueField
        case attributeNameField
        case nameField
    }
    
    struct InterfaceState: Codable {
        let customEventSwitch: Int
        let simulateEventSwitch: Int
        let nameValue: String
        let nameSwitchSelection: Int
        let nameSwitchLength: Int
        let attributionValue: String
        let mailingIdValue: String
        let attributeValue: String
        let attributeName: String
        let booleanValue: Bool
        let typeSwitchSelection: Int
        let typeSwitchLength: Int
        let attributeTypeSwitch: Int
        let statusText: String
        let statusColor: Data
        var editingField: TextField? = nil
        var editingValue: String? = nil
    }
        
    var interfaceState: Data? {
        get {
            let statusColor = self.eventStatus.textColor.data
            var interfaceState = InterfaceState(
                customEventSwitch: customEvent.selectedSegmentIndex,
                simulateEventSwitch: simulateEvent.selectedSegmentIndex,
                nameValue: nameField.text ?? "",
                nameSwitchSelection: nameSwitch.selectedSegmentIndex,
                nameSwitchLength: nameSwitch.numberOfSegments,
                attributionValue: attributionField.text ?? "",
                mailingIdValue: mailingIdField.text ?? "",
                attributeValue: attributeValueField.text ?? "",
                attributeName: attributeNameField.text ?? "",
                booleanValue: booleanSwitch.isOn,
                typeSwitchSelection: typeSwitch.selectedSegmentIndex,
                typeSwitchLength: typeSwitch.numberOfSegments,
                attributeTypeSwitch: attributeTypeSwitch.selectedSegmentIndex,
                statusText: self.eventStatus.text ?? "No status yet",
                statusColor: statusColor
            )
            
            if attributionField.isFirstResponder {
                interfaceState.editingField = .attributionField
                interfaceState.editingValue = attributionField.text
            } else if mailingIdField.isFirstResponder {
                interfaceState.editingField = .mailingIdField
                interfaceState.editingValue = mailingIdField.text
            } else if attributeValueField.isFirstResponder {
                interfaceState.editingField = .attributeValueField
                interfaceState.editingValue = attributeValueField.text
            } else if attributeNameField.isFirstResponder {
                interfaceState.editingField = .attributeNameField
                interfaceState.editingValue = attributeNameField.text
            } else if nameField.isFirstResponder {
                interfaceState.editingField = .nameField
                interfaceState.editingValue = nameField.text
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
            updateTypeSelections(self)
            return
        }
        
        let interfaceState: InterfaceState
        do {
            interfaceState = try PropertyListDecoder().decode(InterfaceState.self, from: data)
        } catch {
            print("Could not decode interface state \(error)")
            return
        }
        
        attributionField.text = interfaceState.attributionValue
        mailingIdField.text = interfaceState.mailingIdValue
        attributeValueField.text = interfaceState.attributeValue
        attributeNameField.text = interfaceState.attributeName
        nameField.text = interfaceState.nameValue
        booleanSwitch.isOn = interfaceState.booleanValue
        customEvent.selectedSegmentIndex = interfaceState.customEventSwitch
        simulateEvent.selectedSegmentIndex = interfaceState.simulateEventSwitch

        resize(control: typeSwitch, count: interfaceState.typeSwitchLength)
        typeSwitch.selectedSegmentIndex = interfaceState.typeSwitchSelection
        
        resize(control: nameSwitch, count: interfaceState.nameSwitchLength)
        nameSwitch.selectedSegmentIndex = interfaceState.nameSwitchSelection
        attributeTypeSwitch.selectedSegmentIndex = interfaceState.attributeTypeSwitch
        
        eventStatus.text = interfaceState.statusText
        eventStatus.textColor = UIColor.from(data: interfaceState.statusColor)
        
        updateTypeSelections(self)
        if let editingField = interfaceState.editingField, let value = interfaceState.editingValue {
            switch editingField {
            case .attributionField:
                attributionField.text = value
                attributionField.becomeFirstResponder()
            case .mailingIdField:
                mailingIdField.text = value
                mailingIdField.becomeFirstResponder()
            case .attributeValueField:
                attributeValueField.text = value
                attributeValueField.becomeFirstResponder()
            case .attributeNameField:
                attributeNameField.text = value
                attributeNameField.becomeFirstResponder()
            case .nameField:
                nameField.text = value
                nameField.becomeFirstResponder()
            }
        }
        
        _interfaceState = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        restoreInterfaceStateIfAvailable()
    }
}
