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

class LogVC: UIViewController {
    @IBOutlet weak var followButton: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!

    var follow = true
    var fileMonitor: FileMonitor? = nil
    var log: URL? = nil {
        didSet {
            if let url = log {
                fileMonitor = FileMonitor(url: url, delegate: self)
            } else {
                fileMonitor?.endMonitoring()
                fileMonitor = nil
            }
        }
    }
    var invert = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.textView.refreshControl = refreshControl

        reloadContents()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fileMonitor?.startMonitoring()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fileMonitor?.endMonitoring()
    }
    
    @IBOutlet weak var swapDirectionButton: UIBarButtonItem!
    @IBAction func swapDirection(_ sender: Any) {
        invert = !invert
        if invert {
            swapDirectionButton.image = UIImage(systemName: "arrow.up.doc.fill")
        } else {
            swapDirectionButton.image = UIImage(systemName: "arrow.down.doc.fill")
        }
        reloadContents()
    }
    
    @objc func handleRefresh() {
        reloadContents()
        textView.refreshControl?.endRefreshing()
    }

    @IBAction func swapFollow(_ sender: Any) {
        follow = !follow
        switch follow {
        case true:
            followButton.image = UIImage(systemName: "arrow.clockwise.circle.fill")
            reloadContents()
        case false:
            followButton.image = UIImage(systemName: "arrow.clockwise.circle")
        }
    }
    
    func reloadContents() {
        if !Thread.isMainThread {
            DispatchQueue.main.sync {
                self.reloadContents()
            }
            return
        }
        guard let log = log, let text = try? String(contentsOf: log) else  {
            return
        }
        if invert {
            textView.text = text.components(separatedBy: .newlines).reversed().joined(separator: "\n")
        } else {
            textView.text = text
        }
    }
}

extension LogVC: FileMonitorDelegate {
    func fileMonitor(_: FileMonitor, observedChangeIn: URL) {
        if follow {
            reloadContents()
        }
    }
}
