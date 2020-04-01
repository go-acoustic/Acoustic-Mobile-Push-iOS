/*
* Copyright © 2019, 2019 Acoustic, L.P. All rights reserved.
*
* NOTICE: This file contains material that is confidential and proprietary to
* Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
* industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
* Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
* prohibited.
*/

import Foundation

extension UIColor {
    static func from(data: Data?) -> UIColor? {
        guard let data = data else {
            return nil
        }
        
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? UIColor
    }

    var data: Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
}
