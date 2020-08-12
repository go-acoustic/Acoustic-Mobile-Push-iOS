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

enum Registration: String, CaseIterable {
    case appKey
    case userId
    case channelId
    case pushToken
    
    func value() -> String {
        switch self {
        case .appKey:
            return MCERegistrationDetails.shared.appKey ?? MCEConfig.shared.appKey ?? "Unknown"
        case .userId:
            return MCERegistrationDetails.shared.userId ?? "Not yet registered with Acoustic"
        case .channelId:
            return MCERegistrationDetails.shared.channelId ?? "Not yet registered with Acoustic"
        case .pushToken:
            if let pushToken = MCERegistrationDetails.shared.pushToken {
                return MCEApiUtil.deviceToken(pushToken)
            }
            return "Not yet registered with APNS"
        }
    }
}
