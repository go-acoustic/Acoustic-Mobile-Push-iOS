// Copyright (c) 2019. Acoustic, L.P. All rights reserved.
// NOTICE: This file contains material that is confidential and proprietary to Acoustic, L.P. and/or other developers. No license is granted under any intellectual or industrial property rights of Acoustic, L.P. except as may be provided in an agreement with Acoustic, L.P. Any unauthorized copying or distribution of content from this file is prohibited.

import Foundation
import WatchKit
import AcousticMobilePushWatch

class RegistrationController: WKInterfaceController {
    @IBOutlet weak var userIdLabel: WKInterfaceLabel!
    @IBOutlet weak var channelIdLabel: WKInterfaceLabel!
    @IBOutlet weak var appKeyLabel: WKInterfaceLabel!
    var observer: NSObjectProtocol? = nil
    
    override func willDisappear() {
        super.willDisappear()
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func willActivate() {
        super.willActivate()
        updateRegistrationLabels()
        observer = NotificationCenter.default.addObserver(forName:   MCENotificationName.MCERegistered.rawValue, object: nil, queue: OperationQueue.main, using: { (note) in
            self.updateRegistrationLabels()
        })
    }
    
    func updateRegistrationLabels() {
        if MCERegistrationDetails.shared.mceRegistered {
            userIdLabel.setText(MCERegistrationDetails.shared.userId)
            channelIdLabel.setText(MCERegistrationDetails.shared.channelId)
            appKeyLabel.setText(MCERegistrationDetails.shared.appKey)
        }
    }
}
