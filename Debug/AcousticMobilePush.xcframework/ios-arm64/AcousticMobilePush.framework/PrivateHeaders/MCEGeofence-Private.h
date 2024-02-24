//
// Copyright (C) 2024 Acoustic, L.P. All rights reserved.
//
// NOTICE: This file contains material that is confidential and proprietary to
// Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
// industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
// Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
// prohibited.
//

@interface MCEGeofence(Private)

+(BOOL)updateRadius: (double)radius locationId: (NSString*)locationId withDatabase: (MCEDatabase*)db;
+(BOOL)upsertLatitude: (double) latitude longitude: (double)longitude radius: (double)radius locationId: (NSString*)locationId withDatabase: (MCEDatabase*)db isCustom:(BOOL)isCustom;
+(BOOL) deleteGeofenceWithLocationId: (NSString*) locationId database: (MCEDatabase*) db;
+(NSMutableSet*)geofencesNearCoordinate: (CLLocationCoordinate2D)coordinate radius: (double)radius withDatabase: (MCEDatabase*)db;
+(BOOL)clearDatabase:(MCEDatabase*)database;
+(void)createTableWithDatabase:(MCEDatabase*)db;
+(instancetype) geofenceWithLocationId: (NSString*)locationId database: (MCEDatabase*)db;

@end
