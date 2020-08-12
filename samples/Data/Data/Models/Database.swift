/*
* Copyright © 2020 Acoustic, L.P. All rights reserved.
*
* NOTICE: This file contains material that is confidential and proprietary to
* Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
* industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
* Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
* prohibited.
*/

import Foundation

enum Database: String, CaseIterable {
    static var queues = [String: MCEDatabaseQueue]()
    case deliveryCertifyAction
    case actionRegistry
    case inApp
    case inbox
    case callback
    case event
    case location
    case attribute
    case inboxQueue
    case registrationQueue
    case attributeQueue
    
    func basename() -> String {
        switch self {
        case .deliveryCertifyAction:
            return "MCEDeliveryCertifyAction.sqlite"
        case .actionRegistry:
            return "MCEPush.sqlite"
        case .inApp:
            return "MCEInApp.sqlite"
        case .inbox:
            return "MCEInbox.sqlite"
        case .callback:
            return "MCECordovaCallbacks.sqlite"
        case .event:
            return "MCEEvents.sqlite"
        case .location:
            return "MCELocation.sqlite"
        case .attribute:
            return "MCEAttributes.sqlite"
        case .inboxQueue:
            return "mceInboxQueue.sql"
        case .registrationQueue:
            return "mceRegistrationQueue.sql"
        case .attributeQueue:
            return "mceAttributesQueue.sql"
        }
    }
    
    func path() -> String {
        return MCEConfig.shared.path(forDatabase: self.basename())
    }
    
    func queue() -> MCEDatabaseQueue {
        if let queue = Database.queues[self.path()] {
            return queue
        }
        if let queue = MCEDatabaseQueue(path: self.path()) {
            Database.queues[self.path()] = queue
            return queue
        } else {
            return MCEDatabaseQueue()
        }        
    }
    
    func name() -> String {
        switch self {
        case .deliveryCertifyAction:
            return "Delivery Certify Action"
        case .actionRegistry:
            return "Action Registry"
        case .inApp:
            return "InApp"
        case .inbox:
            return "Inbox"
        case .callback:
            return "Cordova Callbacks"
        case .event:
            return "Events"
        case .location:
            return "Location"
        case .attribute:
            return "Attributes"
        case .inboxQueue:
            return "Inbox Queue"
        case .registrationQueue:
            return "Registration Queue"
        case .attributeQueue:
            return "Attribute Queue"
        }
    }
    
    func tables() -> [String] {
        var tables = [String]()
        self.queue().inDatabase { (database) in
            if let schema = database?.getSchema() {
                while schema.next() {
                    if schema.string(forColumn: "type") == "table" {
                        if let table = schema.string(forColumn: "name") {
                            tables.append(table)
                        }
                    }
                }
            }
        }
        return tables
    }
    
    func rowCount(table: String) -> Int32 {
        var count: Int32 = 0
        self.queue().inDatabase { (database) in
            do {
                if let results = try database?.executeQuery("SELECT COUNT(*) AS count FROM \(table)", values: []) {
                    results.next()
                    count = results.int(forColumn: "count")
                    results.close()
                }
            } catch {
                print("Unable to execute query \(error)")
            }
            
        }
        return count
    }
    
    func row(table: String, index: Int32, ascending: Bool) -> [String: Any]? {
        let columns = self.columns(table: table)
        var row = [String: Any]()
        self.queue().inDatabase { (database) in
            do {
                if let results = try database?.executeQuery("SELECT rowid, * FROM \(table) ORDER BY rowid \( ascending ? "ASC" : "DESC" ) LIMIT 1 OFFSET \(index)", values: []) {
                    results.next()
                    row["rowid"] = results.int(forColumn: "rowid")
                    for column in columns {
                        if !column.name.localizedCaseInsensitiveContains("longitude") && !column.name.localizedCaseInsensitiveContains("latitude") && !column.name.localizedCaseInsensitiveContains("radius") && column.type.caseInsensitiveCompare("real") == .orderedSame, let date = results.date(forColumn: column.name) {
                            row[column.name] = date
                        } else {
                            row[column.name] = results.string(forColumn: column.name)
                        }
                    }
                    results.close()
                }
            } catch {
                print("Unable to execute query \(error)")
            }

        }
        return row
    }
    
    func columns(table: String) -> [(name:String,type:String)] {
        var columns = [(name:String,type:String)]()
        self.queue().inDatabase { (database) in
            if let schema = database?.getTableSchema(table) {
                while schema.next() {
                    if let column = schema.string(forColumn: "name"), let columnType = schema.string(forColumn: "type") {
                        columns.append((name: column, type: columnType))
                    }
                }
            }
        }
        return columns
    }
}
