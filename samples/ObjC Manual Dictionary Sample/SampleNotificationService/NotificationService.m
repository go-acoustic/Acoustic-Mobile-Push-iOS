/*
 * Copyright © 2016, 2019 Acoustic, L.P. All rights reserved.
 *
 * NOTICE: This file contains material that is confidential and proprietary to
 * Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
 * industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
 * Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
 * prohibited.
 */

#import "NotificationService.h"

@implementation NotificationService

-(instancetype)init {
    NSDictionary * config = @{
                              @"baseUrl": @"https://sdk.ibm.xtify.com",
                              @"appKey": @{
                                      @"dev":  @"INSERT DEV APPKEY HERE",
                                      @"prod": @"INSERT PROD APPKEY HERE"
                                      },
                              @"autoReinitialize": @YES,
                              @"invalidateExistingUser": @NO,
                              @"location": @{
                                      @"autoInitialize": @YES,
                                      @"sync": @{
                                              @"syncRadius": @100000,
                                              @"syncInterval": @300
                                              },
                                      @"geofence": @{
                                              @"accuracy": @"3km"
                                              },
                                      @"ibeacon": @{
                                              @"UUID": @"SET YOUR IBEACON UUID HERE"
                                              }
                                      },
                              @"autoInitialize": @YES,
                              @"sessionTimeout": @20,
                              @"loglevel": @"verbose",
                              @"logfile": @YES,
                              @"watch": @{
                                      @"category": @"mce-watch-category",
                                      @"handoff": @{
                                              @"userActivityName": @"com.mce.application",
                                              @"interfaceController": @"handoff"
                                              }
                                      }
                              };
    
    [MCEConfig sharedInstanceWithDictionary: config];
    return [super init];
}


@end
