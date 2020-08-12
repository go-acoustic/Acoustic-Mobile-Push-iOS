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
import CSV
import ZIPFoundation

class Exporter {
    let archive: Archive
    let url: URL
    let tempDirUrl = FileManager.default.temporaryDirectory
    
    init?() {
        url = tempDirUrl.appendingPathComponent("archive.zip")
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
        if let archive = Archive(url: url, accessMode: .create) {
            self.archive = archive
        } else {
            return nil
        }
    }
    
    func configurationHTML() -> String {
        var body = "<h1>Configuration</h1><table>"
        for config in Config.allCases {
            body += "<tr><th>\(config.rawValue)</th><td>\(config.value())</td>"
        }
        body += "</table>"
        return body
    }
    
    func registrationHTML() -> String {
        var body = "<h1>Registration</h1><table>"
        for registration in Registration.allCases {
            body += "<tr><th>\(registration.rawValue)</th><td>\(registration.value())</td>"
        }
        body += "</table>"
        return body
    }
        
    func recreateTables(sourceDatabase: MCEDatabase, destinationDatabase: MCEDatabase) {
        do {
            let creationResults = try sourceDatabase.executeQuery("SELECT sql FROM sqlite_master WHERE name != \"sqlite_sequence\" AND sql != \"\"", values: [])
            while creationResults.next() {
                if let sql = creationResults.string(forColumn: "sql") {
                    try destinationDatabase.executeUpdate(sql, values: [])
                }
            }
        } catch {
            print("Database error \(error.localizedDescription)")
        }
    }
    
    func insertDataIntoTable(sourceDatabase: MCEDatabase, destinationDatabase: MCEDatabase, table: String) {
        do {
            var columns = [String]()
            if let schema = sourceDatabase.getTableSchema(table) {
                while schema.next() {
                    if let column = schema.string(forColumn: "name") {
                        columns.append(column)
                    }
                }
            }
            
            let results = try sourceDatabase.executeQuery("SELECT * FROM \(table)", values: [])
            while results.next() {
                var values = [Any]()
                var placeholders = [String]()
                for column in columns {
                    let value = results.object(forColumnName: column) ?? ""
                    values.append(value)
                    placeholders.append("?")
                }
                                            
                let sql = "INSERT INTO \(table) (\(columns.joined(separator: ",") )) VALUES( \(placeholders.joined(separator: ",") ) )"
                try destinationDatabase.executeUpdate(sql, values: values)
            }
        } catch {
            print("Database error \(error.localizedDescription)")
        }
    }
    
    func exportCSV(database: MCEDatabase, basename: String, table: String) {
        let csvUrl = tempDirUrl.appendingPathComponent("\(basename) \(table).csv")
        do {
            let stream = OutputStream(url: csvUrl, append: false)!
            let csv = try CSVWriter(stream: stream)
                
            // Write Headers
            var columns = [String]()
            if let schema = database.getTableSchema(table) {
                while schema.next() {
                    if let column = schema.string(forColumn: "name") {
                        columns.append(column)
                    }
                }
                try csv.write(row: columns)
            }
            
            // Write Rows
            let results = try database.executeQuery("SELECT * FROM \(table)", values: [])
            while results.next() {
                var csvValues = [String]()
                for column in columns {
                    csvValues.append( results.string(forColumn: column) ?? "NULL" )
                }
                                            
                try csv.write(row: csvValues)
            }
            
            csv.stream.close()
            
            try archive.addEntry(with: csvUrl.lastPathComponent, relativeTo: csvUrl.deletingLastPathComponent(), compressionMethod: .deflate)
            try FileManager.default.removeItem(at: csvUrl)
        } catch {
            print("Error \(error.localizedDescription)")
        }
    }
    
    func attach(database: Database) {
        var basename = database.basename()
        if basename.hasSuffix(".sql") {
            basename.removeLast(4)
        } else if basename.hasSuffix(".sqlite") {
            basename.removeLast(7)
        }
        
        let sqlUrl = URL(fileURLWithPath: basename + ".sqlite", relativeTo: tempDirUrl)
        if FileManager.default.fileExists(atPath: sqlUrl.path) {
            try? FileManager.default.removeItem(at: sqlUrl)
        }
                    
        // Copy database to unencrypted database
        guard let destinationDatabase = MCEDatabase(path: sqlUrl.path) else {
            return
        }
        destinationDatabase.open()
        
        let tables = database.tables()
        database.queue().inDatabase { (sourceDatabase) in
            guard let sourceDatabase = sourceDatabase else {
                return
            }
            
            self.recreateTables(sourceDatabase: sourceDatabase, destinationDatabase: destinationDatabase)
            for table in tables {
                self.insertDataIntoTable(sourceDatabase: sourceDatabase, destinationDatabase: destinationDatabase, table: table)
                self.exportCSV(database: sourceDatabase, basename: basename, table: table)
            }
        }
        destinationDatabase.close()
        
        do {
            try archive.addEntry(with: sqlUrl.lastPathComponent, relativeTo: sqlUrl.deletingLastPathComponent(), compressionMethod: .deflate)
            try FileManager.default.removeItem(at: sqlUrl)
        } catch {
            print("Unable to attach file \(error)")
        }
    }
    
    func attachAllDatabases() {
        for database in Database.allCases {
            attach(database: database)
        }
    }
    
    func attachLog(log: URL) {
        do {
            try archive.addEntry(with: log.lastPathComponent, relativeTo: log.deletingLastPathComponent(), compressionMethod: .deflate)
        } catch {
            print("Can't read contents of file \(log.absoluteString) because \(error.localizedDescription)")
        }
    }
    
    func attachLogs(logs: [URL]) {
        for log in logs {
            attachLog(log: log)
        }
    }
}
