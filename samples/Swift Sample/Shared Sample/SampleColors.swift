/*
 * Copyright © 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

import UIKit

extension UIColor {
    static var disabled: UIColor { return .lightThemeColor(UIColor.gray, darkThemeColor: UIColor.lightGray) }
    static var tint: UIColor { return lightThemeColor(UIColor(hexString: "047970"), darkThemeColor: UIColor(hexString: "1BF7A8")) }
    static var foreground: UIColor { return .lightThemeColor(.black, darkThemeColor: .white) }
    static var failure: UIColor { return .lightThemeColor(UIColor(hexString: "810000"), darkThemeColor: UIColor(hexString: "C30000")) }
    static var warning: UIColor { return .lightThemeColor(UIColor(hexString: "929000"), darkThemeColor: UIColor(hexString: "C1BA28")) }
    static var success: UIColor { return .lightThemeColor(UIColor(hexString: "008000"), darkThemeColor: UIColor(hexString: "00b200")) }
}
