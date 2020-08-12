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
    case deliveryCertifyAction = "MCEDeliveryCertifyAction.sqlite"
    case actionRegistry = "MCEPush.sqlite"
    case inApp = "MCEInApp.sqlite"
    case inbox = "MCEInbox.sqlite"
    case callback = "MCECordovaCallbacks.sqlite"
    case event = "MCEEvents.sqlite"
    case location = "MCELocation.sqlite"
    case attribute = "MCEAttributes.sqlite"
    case inboxQueue = "mceInboxQueue.sql"
    case registrationQueue = "mceRegistrationQueue.sql"
    case attributeQueue = "mceAttributesQueue.sql"
    
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
//        self.queue().inDatabase { (database) in
//            if let schema = database?.getSchema() {
//                while schema.next() {
//                    if schema.string(forColumn: "type") == "table" {
//                        tables.append(schema.string(forColumn: "name"))
//                    }
//                }
//            }
//        }
        return tables
    }
    
    func columns(table: String) -> [(name:String,type:String)] {
        var columns = [(name:String,type:String)]()
//        self.queue().inDatabase { (database) in
//            if let schema = database?.getTableSchema(table) {
//                while schema.next() {
//                    columns.append((name: schema.string(forColumn: "name"), type: schema.string(forColumn: "type") ))
//                }
//            }
//        }
        return columns
    }
}
