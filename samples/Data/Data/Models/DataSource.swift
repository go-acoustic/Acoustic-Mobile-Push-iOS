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

enum DataSource: Int, CaseIterable {
    case config
    case registration
    case logs
    case database
    
    func name() -> String {
        switch self {
        case .config:
            return "Configuration"
        case .logs:
            return "Log Files"
        case .registration:
            return "Registration"
        case .database:
            return "Database Contents"
        }
    }
    
}
