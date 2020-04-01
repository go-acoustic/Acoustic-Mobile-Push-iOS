/*
* Copyright © 2017, 2020 Acoustic, L.P. All rights reserved.
*
* NOTICE: This file contains material that is confidential and proprietary to
* Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
* industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
* Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
* prohibited.
*/

import WatchKit
import Foundation
import AcousticMobilePushWatch

class InterfaceController: WKInterfaceController {
    @IBOutlet weak var versionLabel: WKInterfaceLabel!
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        versionLabel.setText(MCEWatchSdk.shared.sdkVersion())
    }
}
