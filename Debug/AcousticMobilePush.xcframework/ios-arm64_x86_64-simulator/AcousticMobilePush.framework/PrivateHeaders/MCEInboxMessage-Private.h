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

@interface MCEInboxMessage (Private)

+ (void) createTableWithDatabase: (MCEDatabase * _Nonnull) db;
+ (NSMutableArray * _Nullable) inboxMessagesAscending:(BOOL)ascending withDatabase: (MCEDatabase * _Nonnull) db;
+ (instancetype _Nullable) inboxMessageWithInboxMessageId: (NSString * _Nonnull) inboxMessageId withDatabase: (MCEDatabase * _Nonnull) db;
- (BOOL) insertWithDatabase:(MCEDatabase * _Nonnull) db;
+ (instancetype _Nullable) inboxMessageWithRichContentId:(NSString * _Nonnull)richContentId withDatabase: (MCEDatabase * _Nonnull) db;
- (BOOL) saveWithDatabase:(MCEDatabase * _Nonnull) database;
- (BOOL) deleteWithDatabase:(MCEDatabase * _Nonnull) db;

- (instancetype _Nonnull) initWithResultSet: (MCEResultSet * _Nonnull) results;
+ (instancetype _Nonnull) inboxMessageFromResultSet: (MCEResultSet * _Nonnull) results;

- (instancetype _Nonnull) initWithPayload:(NSDictionary * _Nonnull) payload;
+ (instancetype _Nonnull) inboxMessageFromPayload:(NSDictionary * _Nonnull) payload;

- (NSData * _Nonnull) contentData: (NSError *_Nonnull*_Nonnull)error;
- (NSData * _Nonnull) contentData;

+ (BOOL) clearDatabase: (MCEDatabase * _Nonnull) db;

+ (int) messageCountWithDatabase: (MCEDatabase * _Nonnull) db;
+ (int) unreadMessageCountWithDatabase: (MCEDatabase * _Nonnull) db;

@end
