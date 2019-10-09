// Copyright (c) 2019. Acoustic, L.P. All rights reserved.
// NOTICE: This file contains material that is confidential and proprietary to Acoustic, L.P. and/or other developers. No license is granted under any intellectual or industrial property rights of Acoustic, L.P. except as may be provided in an agreement with Acoustic, L.P. Any unauthorized copying or distribution of content from this file is prohibited.

import Foundation
import WatchKit
import AcousticMobilePushWatch

class EventsController: WKInterfaceController {
    @IBOutlet weak var sendEventStatus: WKInterfaceLabel!
    @IBOutlet weak var queueEventStatus: WKInterfaceLabel!
    @IBOutlet weak var sendQueueStatus: WKInterfaceLabel!
    
    var listeners = [NSObjectProtocol]()
    var queueEventTimer: Timer? = nil
    var sendEventTimer: Timer? = nil
    var sendQueueTimer: Timer? = nil
    
    @IBAction func sendEvent() {
        sendEventStatus.setText("Sending")
        sendEventStatus.setTextColor(.white)
        let event = MCEEvent(name: "watch", type: "watch", timestamp: nil, attributes: ["immediate": true])
        MCEEventService.shared.add(event, immediate: true)
    }
    
    @IBAction func queueEvent() {
        queueEventStatus.setText("Queued")
        queueEventStatus.setTextColor(.white)
        let event = MCEEvent(name: "watch", type: "watch", timestamp: nil, attributes: ["immediate": false])
        MCEEventService.shared.add(event, immediate: false)
    }
    
    @IBAction func sendQueue() {
        sendQueueStatus.setText("Sending")
        sendQueueStatus.setTextColor(.white)
        MCEEventService.shared.sendEvents()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        for listener in listeners {
            NotificationCenter.default.removeObserver(listener)
        }
    }
    
    override func willActivate() {
        super.willActivate()
        listeners.append(NotificationCenter.default.addObserver(forName: MCENotificationName.eventSuccess.rawValue, object: nil, queue: OperationQueue.main, using: { (note) in
            for event in note.userInfo?["events"] as! [MCEEvent]
            {
                if event.type == "watch" && event.name == "watch"
                {
                    self.sendQueueStatus.setText("Received")
                    self.sendQueueStatus.setTextColor(.success)
                    if let sendQueueTimer = self.sendQueueTimer
                    {
                        sendQueueTimer.invalidate()
                    }
                    self.sendQueueTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
                        self.sendQueueStatus?.setText("Idle")
                        self.sendQueueStatus?.setTextColor(.lightGray)
                        self.sendQueueTimer = nil
                    })
                    
                    if event.attributes["immediate"] as! Bool
                    {
                        self.sendEventStatus.setText("Received")
                        self.sendEventStatus.setTextColor(.success)
                        if let sendEventTimer = self.sendEventTimer
                        {
                            sendEventTimer.invalidate()
                        }
                        self.sendEventTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
                            self.sendEventStatus?.setText("Idle")
                            self.sendEventStatus?.setTextColor(.lightGray)
                            self.sendEventTimer = nil
                        })
                    }
                    else
                    {
                        self.queueEventStatus.setText("Received")
                        self.queueEventStatus.setTextColor(.success)
                        if let queueEventTimer = self.queueEventTimer
                        {
                            queueEventTimer.invalidate()
                        }
                        self.queueEventTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
                            self.queueEventStatus?.setText("Idle")
                            self.queueEventStatus?.setTextColor(.lightGray)
                            self.queueEventTimer = nil
                        })
                    }
                }
            }
        }))
        
        listeners.append(NotificationCenter.default.addObserver(forName: MCENotificationName.eventFailure.rawValue, object: nil, queue: OperationQueue.main, using: { (note) in
            
            for event in note.userInfo?["events"] as! [MCEEvent]
            {
                if event.type == "watch" && event.name == "watch"
                {
                    self.sendQueueStatus.setText("Error")
                    self.sendQueueStatus.setTextColor(.failure)
                    if let sendQueueTimer = self.sendQueueTimer
                    {
                        sendQueueTimer.invalidate()
                    }
                    
                    if event.attributes["immediate"] as! Bool
                    {
                        self.sendEventStatus.setText("Error")
                        self.sendEventStatus.setTextColor(.failure)
                        if let sendEventTimer = self.sendEventTimer
                        {
                            sendEventTimer.invalidate()
                        }
                    }
                    else
                    {
                        self.queueEventStatus.setText("Error")
                        self.queueEventStatus.setTextColor(.failure)
                        if let queueEventTimer = self.queueEventTimer
                        {
                            queueEventTimer.invalidate()
                        }
                    }
                }
            }
        }))
    }
}
