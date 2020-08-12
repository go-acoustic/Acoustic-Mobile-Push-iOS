/*
* Copyright © 2020 Acoustic, L.P. All rights reserved.
*
* NOTICE: This file contains material that is confidential and proprietary to
* Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
* industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
* Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
* prohibited.
*/

import UIKit

var darwinMonitorObservers = [String: [UUID: () -> ()] ]()

func handler(center: CFNotificationCenter?, pointer: UnsafeMutableRawPointer?, cfname: CFNotificationName?, pointer2: UnsafeRawPointer?, dictionary: CFDictionary?) -> Void {
    if let cfname = cfname, let observers = darwinMonitorObservers[cfname.rawValue as String] {
        for (_, observer) in observers {
            observer()
        }
    }
}

class DarwinMonitor {
    
    static func invalidatePersistantStorageCache() {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let name = "co.acoustic.mobile.push.perisistent.storage.invalidate.cache"
        let cfname = CFNotificationName(name as CFString)
        CFNotificationCenterPostNotification(center, cfname, nil, nil, true);
    }
    
    static func startMonitoring(name: String, callback: @escaping () -> () ) -> UUID {
        let uuid = UUID()
        if let observers = darwinMonitorObservers[name] {
            var observers = observers
            observers[uuid] = callback
            darwinMonitorObservers[name] = observers
        } else {
            darwinMonitorObservers[name] = [uuid: callback]

            let center = CFNotificationCenterGetDarwinNotifyCenter()
            CFNotificationCenterAddObserver(center, nil, handler, name as CFString, nil, .deliverImmediately)
        }
        
        return uuid
    }
    
    static func endMonitoring(name: String, uuid: UUID) {
        if let observers = darwinMonitorObservers[name] {
            var observers = observers
            observers.removeValue(forKey: uuid)
            darwinMonitorObservers[name] = observers
            if observers.count == 0 {
                let center = CFNotificationCenterGetDarwinNotifyCenter()
                CFNotificationCenterRemoveObserver(center, nil, CFNotificationName(name as CFString), nil)
            }
        }
    }
}
