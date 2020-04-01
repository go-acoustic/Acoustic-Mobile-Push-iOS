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

enum Status
{
    case normal
    case sent
    case failed
    case recieved
    case queued
}

class CellStatusTableViewController: UITableViewController
{
    var status: [String:Status] = ["fake": .normal]
    
    func normalCellStatus(cell: UITableViewCell, key: String, afterDelay: Double)
    {        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) {
                self.status[key] = .normal
                self.tableView.reloadData()
        }
    }
    
    func cellStatus(cell: UITableViewCell, key: String)
    {
        switch(status[key]!)
        {
        case .sent:
            cell.detailTextLabel!.text = "Sending"
            break
        case .recieved:
            cell.detailTextLabel!.text = "Received"
            normalCellStatus(cell: cell, key: key, afterDelay: 5)
            break
        case .failed:
            cell.detailTextLabel!.text = "Failed"
            normalCellStatus(cell: cell, key: key, afterDelay: 5)
            break
        default:
            cell.detailTextLabel!.text = ""
            break
        }
    }
}
