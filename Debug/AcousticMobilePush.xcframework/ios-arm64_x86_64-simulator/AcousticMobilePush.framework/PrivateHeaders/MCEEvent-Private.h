//
// Copyright (C) 2024 Acoustic, L.P. All rights reserved.
//
// NOTICE: This file contains material that is confidential and proprietary to
// Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
// industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
// Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
// prohibited.
//

@class MCEResultSet;
@class MCEDatabase;

@interface MCEEvent(Private)
- (instancetype) initWithResultSet:(MCEResultSet*)results;
- (NSDictionary*) packageEvent;
- (BOOL) insertIntoDatabase:(MCEDatabase*)db;
+ (BOOL) createDatabase: (MCEDatabase*)db;
+ (BOOL) cleanDatabase: (MCEDatabase*)db;
+ (BOOL) createDatabaseIndex: (MCEDatabase*)db;
+ (MCEEvent*) lastEventWithType: (NSString*)type inDatabase: (MCEDatabase*)db;
+ (NSArray<MCEEvent*> *) unsentEventsInDatabase: (MCEDatabase*)db;
+ (BOOL) clearDatabase: (MCEDatabase*)db;
- (BOOL) updateWithDatabase:(MCEDatabase*)db;
- (BOOL) similarEventInDatabase: (MCEDatabase*)db;
@end
