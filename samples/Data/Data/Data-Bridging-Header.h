/*
* Copyright © 2020 Acoustic, L.P. All rights reserved.
*
* NOTICE: This file contains material that is confidential and proprietary to
* Acoustic, L.P. and/or other developers. No license is granted under any intellectual or
* industrial property rights of Acoustic, L.P. except as may be provided in an agreement with
* Acoustic, L.P. Any unauthorized copying or distribution of content from this file is
* prohibited.
*/

@import AcousticMobilePush;

@interface MCEConfig (internal)
-(NSString*) pathForDatabase:(NSString*)basename;
@end

@interface MCEDatabase: NSObject
- (MCEResultSet*)getSchema;
- (MCEResultSet*)getTableSchema:(NSString*)tableName;
- (BOOL)columnExists:(NSString*)columnName inTableWithName:(NSString*)tableName;
- (BOOL)tableExists:(NSString*)tableName;
- (int64_t)lastInsertRowId;
- (BOOL) open;
- (BOOL) close;
- (BOOL)hadError;
+ (instancetype)databaseWithPath:(NSString*)inPath;
- (instancetype)initWithPath:(NSString*)inPath;
- (BOOL)executeUpdate:(NSString*)sql values:(NSArray *)values error:(NSError * __autoreleasing *)error;
- (MCEResultSet *)executeQuery:(NSString *)sql values:(NSArray *)values error:(NSError * __autoreleasing *)error;
@end

@interface MCEDatabaseQueue : NSObject
- (void)inDatabase:(void (^)(MCEDatabase *db))block;
+ (instancetype)databaseQueueWithPath:(NSString*)aPath;
@end

@interface MCEResultSet
- (BOOL)next;
- (int)intForColumn:(NSString*)columnName;
- (id)objectForColumnName:(NSString*)columnName;
- (NSData * __nullable)dataForColumn:(NSString*)columnName;
- (NSString * __nullable)stringForColumn:(NSString*)columnName;
- (NSDate * __nullable)dateForColumn:(NSString*)columnName;
- (void)close;
- (NSDictionary*)resultDictionary;
@end

@interface MCELog : NSObject
@property(class, nonatomic, readonly) MCELog * _Nonnull sharedInstance NS_SWIFT_NAME(shared);
@property NSString * logLevelName;
@property BOOL logToFile;                 // default to false
@end
