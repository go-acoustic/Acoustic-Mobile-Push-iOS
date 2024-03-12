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

@interface MCEInAppMessage (private)
@property BOOL onServer;
- (instancetype _Nonnull) initWithDictionary: (NSDictionary * _Nonnull) dictionary;
+ (BOOL) createTableWithDatabase: (MCEDatabase * _Nonnull) db;
+ (NSMutableArray * _Nonnull) inAppMessagesForIds: (NSSet * _Nonnull) inAppMessageIds withDatabase: (MCEDatabase * _Nonnull) db;
+ (instancetype _Nullable) inAppMessageById: (NSString * _Nonnull) inAppMessageId withDatabase: (MCEDatabase * _Nonnull) db;
- (void) updateWithDictionary: (NSDictionary * _Nonnull) dictionary;
- (BOOL) deleteWithDatabase: (MCEDatabase * _Nonnull) db;
+ (BOOL) clearDatabase: (MCEDatabase * _Nonnull) db;
- (BOOL) insertWithDatabase: (MCEDatabase * _Nonnull) db;
- (BOOL) updateWithDatabase: (MCEDatabase * _Nonnull) db;
@end
