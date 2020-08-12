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

class DatabaseTableDataVC: UITableViewController {
    @IBOutlet weak var followButton: UIBarButtonItem!
    @IBOutlet weak var ascendingButton: UIBarButtonItem!

    var monitorUUID: UUID? = nil
    var database: Database? = nil
    var follow = true
    var ascending = false
 
    @IBAction func swapAscending(_ sender: Any) {
        ascending = !ascending
        switch ascending {
        case true:
            ascendingButton.image = UIImage(systemName: "arrow.up.doc.fill")
        case false:
            ascendingButton.image = UIImage(systemName: "arrow.down.doc.fill")
        }
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let database = database {
            let url = URL(fileURLWithPath: database.path())
            monitorUUID = DarwinMonitor.startMonitoring(name: "co.acoustic.mobile.push.database." + url.lastPathComponent, callback: {
                if self.follow {
                    self.tableView.reloadData()
                }
            })
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54
    }
        
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        guard let database = database, let table = table else {
            return view
        }
        
        let text = UILabel()
        
        let smallCapsDesc = UIFont.systemFont(ofSize: UIFont.labelFontSize).fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.featureSettings: [
                [
                    UIFontDescriptor.FeatureKey.featureIdentifier: kUpperCaseType,
                    UIFontDescriptor.FeatureKey.typeIdentifier: kUpperCaseSmallCapsSelector
                ]
            ]
        ])
        text.font = UIFont(descriptor: smallCapsDesc, size: UIFont.labelFontSize)
        text.textColor = UIColor.secondaryLabel
        text.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(text)
        
        let button = UIButton()        
        if let result = database.row(table: table, index: Int32(section), ascending: ascending), let rowid =  result["rowid"] as? Int32 {
            button.tag = Int(rowid)
            text.text = "Row \(rowid)"
        }
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.addTarget(self, action: #selector(deleteRow(_:)), for: .touchUpInside)
        
        let views = ["button": button, "view": view, "text": text]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[text]-[button(==44)]-|", options: .init(), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[button]-4-|", options: .init(), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[text]-4-|", options: .init(), metrics: nil, views: views))

        return view
    }

    @objc func deleteRow(_ sender: UIButton) {
        let alert = UIAlertController(title: "Please Confirm", message: "Do you want to remove this row?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.database?.queue().inDatabase({ (database) in
                guard let database = database, let table = self.table else {
                    return
                }
                try? database.executeUpdate("DELETE FROM \(table) WHERE rowid = ?", values: [sender.tag])
            })
        }))
        present(alert, animated: true)
    }
    
    @IBAction func clearTable(_ sender: Any) {
        let alert = UIAlertController(title: "Please Confirm", message: "Do you want to clear the entire database?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.database?.queue().inDatabase({ (database) in
                guard let database = database, let table = self.table else {
                    return
                }
                try? database.executeUpdate("DELETE FROM \(table)", values: [])
            })
        }))
        present(alert, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let database = database, let uuid = monitorUUID {
            let url = URL(fileURLWithPath: database.path())
            DarwinMonitor.endMonitoring(name: url.lastPathComponent, uuid: uuid)
        }
    }
    
    var table: String? = nil
    var columns: [(name:String,type:String)]? = nil
    
    @objc func handleRefresh() {
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }
    
    @IBAction func refresh(_ sender: Any) {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let database = database, let table = table else {
            return;
        }
        columns = database.columns(table: table)
        navigationItem.title = "\(database.name()) database's \(table) rows"

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basic", for: indexPath)
        guard let database = database, let table = table, let columns = columns, let entry = database.row(table: table, index: Int32(indexPath.section), ascending: ascending) else {
            return cell
        }
        
        let column = columns[indexPath.row]
        cell.textLabel?.text = column.name
        cell.detailTextLabel?.text = String(describing: entry[column.name] ?? "NULL")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let database = database, let table = table, let columns = columns, let entry = database.row(table: table, index: Int32(indexPath.section), ascending: ascending) else {
            return
        }
        let column = columns[indexPath.row]
        UIPasteboard.general.string = String(describing: entry[column.name] ?? "NULL")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let database = database, let table = table else {
            return 0
        }
        return Int(database.rowCount(table: table))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let columns = columns else {
            return 0
        }
        return columns.count
    }
}
