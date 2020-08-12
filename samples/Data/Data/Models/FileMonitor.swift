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

protocol FileMonitorDelegate {
    func fileMonitor(_: FileMonitor, observedChangeIn: URL)
}

// This is triggered when the file is opened / closed, but not when SQLite updates a database since it's kept open
class FileMonitor {
    var url: URL
    var fileDescriptor: Int32? = nil
    var source: DispatchSourceFileSystemObject? = nil
    var delegate: FileMonitorDelegate
    
    init(url: URL, delegate: FileMonitorDelegate) {
        self.url = url
        self.delegate = delegate
    }
    
    func startMonitoring() {
        endMonitoring()
        
        fileDescriptor = open(url.path, O_EVTONLY)
        source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor!, eventMask: DispatchSource.FileSystemEvent([.all]))
        
        source?.setEventHandler {
            self.delegate.fileMonitor(self, observedChangeIn: self.url)
        }

        source?.setCancelHandler {
            self.endMonitoring()
        }

        source?.resume()
    }
    
    func endMonitoring() {
        if let fileDescriptor = fileDescriptor {
            close(fileDescriptor)
        }
        fileDescriptor = nil
        source = nil
    }
    
}
