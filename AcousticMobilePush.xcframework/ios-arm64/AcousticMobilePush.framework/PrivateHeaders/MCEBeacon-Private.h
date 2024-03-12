//
// Copyright (C) 2024 Acoustic, L.P. All rights reserved.
//
// NOTICE: This file contains material that is confidential and proprietary to
// Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
// industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
// Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
// prohibited.
//

@interface MCEBeacon(Private)

+ (void) createTableWithDatabase:(MCEDatabase*)db;
+(BOOL)upsertMajor:(int)major minor:(int)minor locationId:(NSString*)locationId withDatabase:(MCEDatabase*)db;
+(BOOL) deleteBeaconWithLocationId: (NSString*) locationId database: (MCEDatabase*)db;
+(NSMutableSet*)beaconRegionsWithUUID: (NSUUID*)uuid database:(MCEDatabase *)db;
+(instancetype)beaconWithMajor:(NSNumber*)major minor:(NSNumber*)minor database:(MCEDatabase*)database;
+(BOOL)clearDatabase:(MCEDatabase*)database;

@end
