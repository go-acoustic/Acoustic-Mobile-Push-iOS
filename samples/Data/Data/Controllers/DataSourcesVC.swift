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
import MessageUI

extension DataSourcesVC : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

class DataSourcesVC: UITableViewController {
    var darwinMonitors = [(name: String, uuid: UUID)]()

    @IBAction func sendEmail(_ sender: Any) {
        if !MFMailComposeViewController.canSendMail() {
            let alert = UIAlertController(title: "Mail services are not available", message: "Please configure at least one mail account before using this feature", preferredStyle: .alert)
            present(alert, animated: true)
            return
        }

        guard let exporter = Exporter() else {
            let alert = UIAlertController(title: "Couldn't create archive", message: nil, preferredStyle: .alert)
            present(alert, animated: true)
            return
        }
        exporter.attachAllDatabases()
        exporter.attachLogs(logs: logs)
        
        let mailViewController = MFMailComposeViewController()
        guard let data = try? Data(contentsOf: exporter.url) else {
            let alert = UIAlertController(title: "Couldn't read archive", message: nil, preferredStyle: .alert)
            present(alert, animated: true)
            return
        }
        
        mailViewController.addAttachmentData(data, mimeType: "application/zip", fileName: exporter.url.lastPathComponent)
        mailViewController.mailComposeDelegate = self
        let body = exporter.configurationHTML() + exporter.registrationHTML()
        mailViewController.setMessageBody(body, isHTML: true)
        mailViewController.setSubject("Sample App Data")
        mailViewController.setMessageBody(body, isHTML: true)
        present(mailViewController, animated: true)
    }
    
    var inboxSyncStatus = "Inbox status"
    lazy var logs: [URL] = {
        var logs = [URL]()
        guard let dummy = MCEConfig.shared.path(forDatabase: "dummy.log") else {
            return logs
        }
        let dummyURL = URL(fileURLWithPath: dummy)
        let directory = dummyURL.deletingLastPathComponent()
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)
            for url in contents {
                if url.pathExtension == "log" {
                    logs.append(url)
                }
            }
        } catch {
            print("Can't list shared directory \(error)")
        }

        return logs
    }()
    
    @IBAction func refresh(_ sender: Any) {
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DataSource(rawValue: section)?.name()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basic", for: indexPath)
        guard let source = DataSource(rawValue: indexPath.section) else {
            return cell
        }

        switch source {
        case .config:
            let config = Config.allCases[indexPath.item]
            cell.textLabel?.text = config.rawValue
            cell.detailTextLabel?.text = config.value()
            break
        case .logs:
            cell.textLabel?.text = logs[indexPath.item].lastPathComponent
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: logs[indexPath.item].path)
                let size = attributes[.size] as? NSNumber
                
                if let size = size {
                    let formatter = ByteCountFormatter()
                    formatter.includesActualByteCount = true
                    cell.detailTextLabel?.text = formatter.string(fromByteCount: size.int64Value)
                }
            } catch {
                print("Attributes can't be requested for url \(error)")
            }
        case .registration:
            let registration = Registration.allCases[indexPath.item]
            cell.textLabel?.text = registration.rawValue
            cell.detailTextLabel?.text = registration.value()
            break
        case .database:
            let database = Database.allCases[indexPath.item]
            cell.textLabel?.text = database.name()
            let tables = database.tables()
            let rows = tables.reduce(0) { (count, table) -> Int32 in
                return count + database.rowCount(table: table)
            }
            cell.detailTextLabel?.text = String.localizedStringWithFormat(NSLocalizedString("contains %d tables with %d rows", comment: "number of rows in all tables"), tables.count, rows)

        }

        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return DataSource.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let source = DataSource(rawValue: section) else {
            return 0
        }

        switch source {
        case .config:
            return Config.allCases.count
        case .logs:
            return logs.count
        case .database:
            return Database.allCases.count
        case .registration:
            return Registration.allCases.count
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let source = DataSource(rawValue: indexPath.section) else {
            return
        }

        switch source {
        case .config:
            UIPasteboard.general.string = Config.allCases[indexPath.item].value()
        case .logs:
            guard let logViewController = storyboard?.instantiateViewController(withIdentifier: "Logs") as? LogVC else {
                return
            }
            logViewController.log = logs[indexPath.item]
            navigationController?.pushViewController(logViewController, animated: true)
        case .registration:
            UIPasteboard.general.string = Registration.allCases[indexPath.item].value()
        case .database:
            guard let databaseTables = storyboard?.instantiateViewController(withIdentifier: "DatabaseTable") as? DatabaseTableVC else {
                return
            }
            databaseTables.database = Database.allCases[indexPath.item]
            navigationController?.pushViewController(databaseTables, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        
        for database in Database.allCases {
            let name = database.basename()
            let uuid = DarwinMonitor.startMonitoring(name: name) {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            darwinMonitors.append( (name: name, uuid: uuid) )
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        for item in darwinMonitors {
            DarwinMonitor.endMonitoring(name: item.name, uuid: item.uuid)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        self.refreshControl = refreshControl
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }

    @objc func handleRefreshControl() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }

}
