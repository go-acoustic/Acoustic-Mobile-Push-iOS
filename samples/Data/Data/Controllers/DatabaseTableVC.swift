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

class DatabaseTableVC: UITableViewController {
    var monitorUUID: UUID? = nil
    var database: Database? = nil
    @IBOutlet weak var followButton: UIBarButtonItem!
    var follow = true

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
        if let database = database {
            let url = URL(fileURLWithPath: database.path())
            monitorUUID = DarwinMonitor.startMonitoring(name: "co.acoustic.mobile.push.database." + url.lastPathComponent, callback: {
                if self.follow {
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let database = database, let uuid = monitorUUID {
            let url = URL(fileURLWithPath: database.path())
            DarwinMonitor.endMonitoring(name: url.lastPathComponent, uuid: uuid)
        }
    }

    @IBAction func swapFollow(_ sender: Any) {
        follow = !follow
        switch follow {
        case true:
            followButton.image = UIImage(systemName: "arrow.clockwise.circle.fill")
            tableView.reloadData()
        case false:
            followButton.image = UIImage(systemName: "arrow.clockwise.circle")
        }
    }

    @objc func handleRefresh() {
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
        guard let database = database else {
            return;
        }
        navigationItem.title = "\(database.name()) database's tables"
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let database = database else {
            return ""
        }
        let table = database.tables()[section]
        
        let rows = database.rowCount(table: table)
        return String.localizedStringWithFormat(NSLocalizedString("%@ table has %d rows", comment: "number of rows in table"), table, rows)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basic", for: indexPath)
        guard let database = database else {
            return cell
        }
        let table = database.tables()[indexPath.section]
        let columns = database.columns(table: table)
        let column = columns[indexPath.row]
        cell.textLabel?.text = column.name
        cell.detailTextLabel?.text = column.type
    
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let database = database else {
            return 0
        }
        return database.tables().count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let database = database else {
            return 0
        }
        let table = database.tables()[section]
        let columns = database.columns(table: table)
        return columns.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let database = database, let databaseTableData = storyboard?.instantiateViewController(withIdentifier: "DatabaseTableData") as? DatabaseTableDataVC else {
            return
        }
        databaseTableData.database = database
        databaseTableData.table = database.tables()[indexPath.section]
        navigationController?.pushViewController(databaseTableData, animated: true)
    }
}
