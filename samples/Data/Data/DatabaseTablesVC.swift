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
    var database: Databases? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let database = database else {
            return;
        }
        navigationItem.title = database.name()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let database = database else {
            return ""
        }
        return database.tables()[section]
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
}
