// Copyright (c) 2019. Acoustic, L.P. All rights reserved.
// NOTICE: This file contains material that is confidential and proprietary to Acoustic, L.P. and/or other developers. No license is granted under any intellectual or industrial property rights of Acoustic, L.P. except as may be provided in an agreement with Acoustic, L.P. Any unauthorized copying or distribution of content from this file is prohibited.

import Foundation
import WatchKit
import AcousticMobilePushWatch

class AttributesController: WKInterfaceController {
    var listeners = [NSObjectProtocol]()
    var deleteTimer: Timer? = nil
    var updateTimer: Timer? = nil
    @IBOutlet weak var updateAttributeStatus: WKInterfaceLabel!
    @IBOutlet weak var deleteAttributeStatus: WKInterfaceLabel!
    
    @IBAction func updateAttribute() {
        updateAttributeStatus.setText("Sending")
        updateAttributeStatus.setTextColor(.white)
        MCEAttributesQueueManager.shared.updateUserAttributes(["onwatch": arc4random()])
    }
    
    @IBAction func deleteAttribute() {
        deleteAttributeStatus.setText("Sending")
        deleteAttributeStatus.setTextColor(.white)
        MCEAttributesQueueManager.shared.deleteUserAttributes(["onwatch"])
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        arc4random_stir()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        for listener in listeners {
            NotificationCenter.default.removeObserver(listener)
        }
    }
    
    override func willActivate() {
        super.willActivate()
        
        listeners.append(NotificationCenter.default.addObserver(forName: MCENotificationName.UpdateUserAttributesError.rawValue, object: nil, queue: OperationQueue.main, using: { (note) in
            if let userInfo = note.userInfo
            {
                if let attributes = userInfo["attributes"] as? Dictionary<AnyHashable,Any>
                {
                    if attributes["onwatch"] != nil
                    {
                        self.updateAttributeStatus.setText("Error")
                        self.updateAttributeStatus.setTextColor(.failure)
                    }
                }
            }
        }))
        
        listeners.append(NotificationCenter.default.addObserver(forName: MCENotificationName.UpdateUserAttributesSuccess.rawValue, object: nil, queue: OperationQueue.main, using: { (note) in
            if let userInfo = note.userInfo
            {
                if let attributes = userInfo["attributes"] as? Dictionary<AnyHashable,Any>
                {
                    if attributes["onwatch"] != nil
                    {
                        self.updateAttributeStatus.setText("Received")
                        self.updateAttributeStatus.setTextColor(.success)
                        if let updateTimer = self.updateTimer
                        {
                            updateTimer.invalidate()
                        }
                        self.updateTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
                            self.updateAttributeStatus.setTextColor(.lightGray)
                            self.updateAttributeStatus.setText("Idle")
                            self.updateTimer = nil
                        })
                    }
                }
            }
        }))
        
        listeners.append(NotificationCenter.default.addObserver(forName: MCENotificationName.DeleteUserAttributesError.rawValue, object: nil, queue: OperationQueue.main, using: { (note) in
            if let userInfo = note.userInfo
            {
                if let attributes = userInfo["attributes"] as? Dictionary<AnyHashable,Any>
                {
                    if attributes["onwatch"] != nil
                    {
                        self.deleteAttributeStatus.setText("Error")
                        self.deleteAttributeStatus.setTextColor(.failure)
                    }
                }
            }
        }))
        
        listeners.append(NotificationCenter.default.addObserver(forName: MCENotificationName.DeleteUserAttributesSuccess.rawValue, object: nil, queue: OperationQueue.main, using: { (note) in
            if let userInfo = note.userInfo
            {
                if let keys = userInfo["keys"] as? Array<String>
                {
                    if keys.firstIndex(of: "onwatch") != NSNotFound
                    {
                        self.deleteAttributeStatus.setText("Received")
                        self.deleteAttributeStatus.setTextColor(.success)
                        if let deleteTimer = self.deleteTimer
                        {
                            deleteTimer.invalidate()
                        }
                        self.deleteTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
                            self.deleteAttributeStatus.setTextColor(.lightGray)
                            self.deleteAttributeStatus.setText("Idle")
                            self.deleteTimer = nil
                        })
                    }
                }
            }
        }))
    }
}
