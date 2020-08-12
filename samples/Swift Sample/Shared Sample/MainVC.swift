/*
 * Copyright © 2015, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

import UIKit
import AcousticMobilePush

class MainVC : UITableViewController
{
    @IBOutlet weak var version: UILabel?
    @IBOutlet weak var inboxCell: UITableViewCell?
    @IBOutlet weak var altInboxCell: UITableViewCell?
    
    var previewingContext: UIViewControllerPreviewing?
    
    // Hide iBeacons when on Mac
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        #if targetEnvironment(macCatalyst)
        if indexPath.item == 7 {
            return 0
        }
        #endif

        return 44
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inboxUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        version!.text = "Native SDK v\(MCESdk.shared.sdkVersion())"
        
        // Show Inbox counts on main page
        NotificationCenter.default.addObserver(self, selector: #selector(MainVC.inboxUpdate), name: MCENotificationName.InboxCountUpdate.rawValue, object: nil)
        if(MCERegistrationDetails.shared.mceRegistered)
        {
            MCEInboxQueueManager.shared.syncInbox()
        }
        else
        {
            NotificationCenter.default.addObserver(forName: MCENotificationName.MCERegistered.rawValue, object: nil, queue: .main, using: { (note) in
                MCEInboxQueueManager.shared.syncInbox()
            })
        }
    }
    
    // Show Inbox counts on main page
    @objc func inboxUpdate()
    {
        let unreadCount = MCEInboxDatabase.shared.unreadMessageCount()
        let messageCount = MCEInboxDatabase.shared.messageCount()
        
        var subtitle = ""
        if MCERegistrationDetails.shared.mceRegistered
        {
            subtitle = "\(messageCount) messages, \(unreadCount) unread"
        }
        
        DispatchQueue.main.async {
            self.inboxCell?.detailTextLabel?.text = subtitle
            self.altInboxCell?.detailTextLabel?.text = subtitle
            self.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        guard let identifier = cell?.accessibilityIdentifier else {
            print("Couldn't determine view controller to show!")
            return
        }
        
        start(identifier: identifier)
    }
    
    func start(identifier: String) {
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: identifier) else {
            print("Couldn't find view controller to show")
            return
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let navigationController = UINavigationController(rootViewController: viewController)
            viewController.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            viewController.navigationItem.leftItemsSupplementBackButton = true
            splitViewController?.showDetailViewController(navigationController, sender: self)
        } else {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
