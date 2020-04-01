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

enum Config {
    static var mobilePushConfig: [String: Any] {
        return [
            "Please note": "you will need to update your baseUrl to the one supplied to you",
            "baseUrl": "https://mobile-sdk-lib-XX-Y.brilliantcollector.com",

            "appKey": [
                "dev":  "INSERT DEV APPKEY HERE",
                "prod": "INSERT PROD APPKEY HERE"
            ],
            "autoReinitialize": true,
            "invalidateExistingUser": false,
            "location": [
                "autoInitialize": true,
                "sync": [
                    "syncRadius": 100000,
                    "syncInterval": 300
                ],
                "geofence": [
                    "accuracy": "3km"
                ],
                "ibeacon": [
                    "UUID": "SET YOUR IBEACON UUID HERE"
                ]
            ],
            "autoInitialize": true,
            "sessionTimeout": 20,
            "loglevel": "verbose",
            "logfile": true,
            "watch": [
                "category": "mce-watch-category",
                "handoff": [
                    "userActivityName": "com.mce.application",
                    "interfaceController": "handoff"
                ]
            ]
        ]
    }
}
