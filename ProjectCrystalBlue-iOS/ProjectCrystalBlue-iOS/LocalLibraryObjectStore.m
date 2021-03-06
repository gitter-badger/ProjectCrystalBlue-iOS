//
//  LocalLibraryObjectStore.m
//  ProjectCrystalBlue-iOS
//
//  Created by Justin Baumgartner on 2/6/14.
//  Copyright (c) 2014 Project Crystal Blue. All rights reserved.
//

#import "LocalLibraryObjectStore.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMResultSet.h"
#import "Sample.h"
#import "SampleImageUtils.h"
#import "Split.h"
#import "PCBLogWrapper.h"

@interface LocalLibraryObjectStore()
{
    FMDatabaseQueue *localQueue;
}

/*  Creates the sqlite Sample and Split tables if they do not already exist.
 */
- (void)setupTables;

@end


@implementation LocalLibraryObjectStore

- (id)initInLocalDirectory:(NSString *)directory
          WithDatabaseName:(NSString *)databaseName
{
    self = [super initInLocalDirectory:directory WithDatabaseName:databaseName];
    if (self) {
        // Setup local directory
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *localDirectory = [documentsDirectory stringByAppendingPathComponent:directory];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:localDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
        
        localQueue = [FMDatabaseQueue databaseQueueWithPath:[localDirectory stringByAppendingPathComponent:databaseName]];
        
        // Setup tables
        [self setupTables];
    }
    return self;
}

- (LibraryObject *)getLibraryObjectForKey:(NSString *)key
                                FromTable:(NSString *)tableName
{
    if (![tableName isEqualToString:[SampleConstants tableName]] && ![tableName isEqualToString:[SplitConstants tableName]]) {
        DDLogCError(@"%@: Invalid table name. Use the SampleConstants or SplitConstants tableName.", NSStringFromClass(self.class));
        return nil;
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE KEY='%@'", tableName, key];
    
    // Get library object with key
    __block NSDictionary *resultDictionary = nil;
    [localQueue inDatabase:^(FMDatabase *localDatabase) {
        FMResultSet *results = [localDatabase executeQuery:sql];
        
        if (localDatabase.hadError) {
            DDLogCError(@"%@: Failed to get library object from local database. Error: %@", NSStringFromClass(self.class), localDatabase.lastError);
            [results close];
            [[NSException exceptionWithName:@"SQLiteException" reason:@"SQLite failed to get the library object." userInfo:nil] raise];
        }
        
        // Have the library object's attributes
        else if (results.next)
            resultDictionary = results.resultDictionary;
        [results close];
    }];
    
    if (!resultDictionary)
        return nil;
    
    // Create a new Sample or Split object
    if ([tableName isEqualToString:[SampleConstants tableName]])
        return [[Sample alloc] initWithKey:key AndWithAttributeDictionary:resultDictionary];
    else
        return [[Split alloc] initWithKey:key AndWithAttributeDictionary:resultDictionary];
}

- (NSArray *)getAllLibraryObjectsFromTable:(NSString *)tableName
{
    if (![tableName isEqualToString:[SampleConstants tableName]] && ![tableName isEqualToString:[SplitConstants tableName]]) {
        DDLogCError(@"%@: Invalid table name. Use the SampleConstants or SplitConstants tableName.", NSStringFromClass(self.class));
        return nil;
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@", tableName];
    
    // Get all library objects from table
    __block NSMutableArray *libraryObjects = [[NSMutableArray alloc] init];;
    [localQueue inDatabase:^(FMDatabase *localDatabase) {
        FMResultSet *results = [localDatabase executeQuery:sql];
        
        if (localDatabase.hadError) {
            DDLogCError(@"%@: Failed to get all library objects from local database. Error: %@", NSStringFromClass(self.class), localDatabase.lastError);
            [results close];
            [[NSException exceptionWithName:@"SQLiteException" reason:@"SQLite failed to get all library objects from table." userInfo:nil] raise];
        }
        
        // Add all the results to the libraryObjects array
        while (results.next) {
            NSString *key = [results.resultDictionary objectForKey:@"KEY"];
            if ([tableName isEqualToString:[SampleConstants tableName]])
                [libraryObjects addObject:[[Sample alloc] initWithKey:key AndWithAttributeDictionary:results.resultDictionary]];
            else
                [libraryObjects addObject:[[Split alloc] initWithKey:key AndWithAttributeDictionary:results.resultDictionary]];
        }
        [results close];
    }];
    
    return libraryObjects;
}

- (NSArray *)getAllSplitsForSampleKey:(NSString *)sampleKey
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@'", [SplitConstants tableName], SPL_SAMPLE_KEY, sampleKey];
    
    // Get all corresponding splits from table
    __block NSMutableArray *splits = [[NSMutableArray alloc] init];;
    [localQueue inDatabase:^(FMDatabase *localDatabase) {
        FMResultSet *results = [localDatabase executeQuery:sql];
        
        if (localDatabase.hadError) {
            DDLogCError(@"%@: Failed to get all splits for sample key. Error: %@", NSStringFromClass(self.class), localDatabase.lastError);
            [results close];
            [[NSException exceptionWithName:@"SQLiteException" reason:@"SQLite failed to get all splits for sample key." userInfo:nil] raise];
        }
        
        // Add all the results to the splits array
        while (results.next) {
            NSString *key = [results.resultDictionary objectForKey:@"KEY"];
            [splits addObject:[[Split alloc] initWithKey:key AndWithAttributeDictionary:results.resultDictionary]];
        }
        [results close];
    }];
    
    return splits;
}

- (NSArray *)getAllLibraryObjectsForAttributeName:(NSString *)attributeName
                               WithAttributeValue:(NSString *)attributeValue
                                        FromTable:(NSString *)tableName
{
    if (![tableName isEqualToString:[SampleConstants tableName]] && ![tableName isEqualToString:[SplitConstants tableName]]) {
        DDLogCError(@"%@: Invalid table name. Use the SampleConstants or SplitConstants tableName.", NSStringFromClass(self.class));
        return nil;
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ LIKE '%%%@%%'", tableName, attributeName, attributeValue];
    
    // Get all corresponding splits from table
    __block NSMutableArray *libraryObjects = [[NSMutableArray alloc] init];;
    [localQueue inDatabase:^(FMDatabase *localDatabase) {
        FMResultSet *results = [localDatabase executeQuery:sql];
        
        if (localDatabase.hadError) {
            DDLogCError(@"%@: Failed to get all library objects for attributeName. Error: %@", NSStringFromClass(self.class), localDatabase.lastError);
            [results close];
            [[NSException exceptionWithName:@"SQLiteException" reason:@"SQLite failed to get all library objects for attributeName." userInfo:nil] raise];
        }
        
        // Add all the results to the splits array
        while (results.next) {
            NSString *key = [results.resultDictionary objectForKey:@"KEY"];
            if ([tableName isEqualToString:[SampleConstants tableName]])
                [libraryObjects addObject:[[Sample alloc] initWithKey:key AndWithAttributeDictionary:results.resultDictionary]];
            else
                [libraryObjects addObject:[[Split alloc] initWithKey:key AndWithAttributeDictionary:results.resultDictionary]];
        }
        [results close];
    }];
    
    return libraryObjects;
}

- (NSArray *)getAllSplitsForSampleKey:(NSString *)sampleKey
                  AndForAttributeName:(NSString *)attributeName
                   WithAttributeValue:(NSString *)attributeValue
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@='%@' AND %@ LIKE '%%%@%%'", [SplitConstants tableName], SPL_SAMPLE_KEY, sampleKey, attributeName, attributeValue];
    
    // Get all corresponding splits from table
    __block NSMutableArray *splits = [[NSMutableArray alloc] init];;
    [localQueue inDatabase:^(FMDatabase *localDatabase) {
        FMResultSet *results = [localDatabase executeQuery:sql];
        
        if (localDatabase.hadError) {
            DDLogCError(@"%@: Failed to get all library objects for attributeName. Error: %@", NSStringFromClass(self.class), localDatabase.lastError);
            [results close];
            [[NSException exceptionWithName:@"SQLiteException" reason:@"SQLite failed to get all library objects for attributeName." userInfo:nil] raise];
        }
        
        // Add all the results to the splits array
        while (results.next) {
            NSString *key = [results.resultDictionary objectForKey:@"KEY"];
            [splits addObject:[[Split alloc] initWithKey:key AndWithAttributeDictionary:results.resultDictionary]];
        }
        [results close];
    }];
    
    return splits;
}

- (NSArray *)getUniqueAttributeValuesForAttributeName:(NSString *)attributeName
                                            FromTable:(NSString *)tableName
{
    if (![tableName isEqualToString:[SampleConstants tableName]] && ![tableName isEqualToString:[SplitConstants tableName]]) {
        DDLogCError(@"%@: Invalid table name. Use the SampleConstants or SplitConstants tableName.", NSStringFromClass(self.class));
        return nil;
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT DISTINCT %@ FROM %@", attributeName, tableName];
    
    // Get all corresponding splits from table
    __block NSMutableArray *attributeValues = [[NSMutableArray alloc] init];;
    [localQueue inDatabase:^(FMDatabase *localDatabase) {
        FMResultSet *results = [localDatabase executeQuery:sql];
        
        if (localDatabase.hadError) {
            DDLogCError(@"%@: SQLite failed to get all distinct attribute values for attributeName. Error: %@", NSStringFromClass(self.class), localDatabase.lastError);
            [results close];
            [[NSException exceptionWithName:@"SQLiteException" reason:@"SQLite failed to get all distinct attribute values for attributeName." userInfo:nil] raise];
        }
        
        // Add all the results to the splits array
        while (results.next) {
            [attributeValues addObject:[results.resultDictionary objectForKey:attributeName]];
        }
        [results close];
    }];
    
    return attributeValues;
}

- (NSArray *)getLibraryObjectsWithSqlQuery:(NSString *)sql
                                   OnTable:(NSString *)tableName
{
    if (![tableName isEqualToString:[SampleConstants tableName]] && ![tableName isEqualToString:[SplitConstants tableName]]) {
        DDLogCError(@"%@: Invalid table name. Use the SampleConstants or SplitConstants tableName.", NSStringFromClass(self.class));
        return nil;
    }
    if (![[sql uppercaseString] hasPrefix:@"SELECT"]) {
        DDLogCError(@"%@: Invalid sql command type. Only use this function to execute queries!", NSStringFromClass(self.class));
        return nil;
    }
    // Execute sql query
    __block NSMutableArray *libraryObjects = [[NSMutableArray alloc] init];
    [localQueue inDatabase:^(FMDatabase *localDatabase) {
        FMResultSet *results = [localDatabase executeQuery:sql];
        
        if (localDatabase.hadError) {
            DDLogCError(@"%@: Failed to execute query on database. Error: %@", NSStringFromClass(self.class), localDatabase.lastError);
            [results close];
            [[NSException exceptionWithName:@"SQLiteException" reason:@"SQLite failed to execute sql query." userInfo:nil] raise];
        }
        
        // Add all the results to the libraryObjects array
        while (results.next) {
            NSString *key = [results.resultDictionary objectForKey:@"KEY"];
            if ([tableName isEqualToString:[SampleConstants tableName]])
                [libraryObjects addObject:[[Sample alloc] initWithKey:key AndWithAttributeDictionary:results.resultDictionary]];
            else
                [libraryObjects addObject:[[Split alloc] initWithKey:key AndWithAttributeDictionary:results.resultDictionary]];
        }
        [results close];
    }];
    
    return libraryObjects;
}

- (BOOL)putLibraryObject:(LibraryObject *)libraryObject
               IntoTable:(NSString *)tableName
{
    if (![tableName isEqualToString:[SampleConstants tableName]] && ![tableName isEqualToString:[SplitConstants tableName]]) {
        DDLogCError(@"%@: Invalid table name. Use the SampleConstants or SplitConstants tableName.", NSStringFromClass(self.class));
        return NO;
    }
    // Update instead if already exists
    if ([self libraryObjectExistsForKey:libraryObject.key FromTable:tableName]) {
        [self updateLibraryObject:libraryObject IntoTable:tableName];
        return YES;
    }
    // Setup sql query
    NSString *sql;
    if ([tableName isEqualToString:[SampleConstants tableName]])
        sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)",
               tableName, [SampleConstants tableColumns], [SampleConstants tableValueKeys]];
    else
        sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)",
               tableName, [SplitConstants tableColumns], [SplitConstants tableValueKeys]];
    
    // FMDB will use the attributes dictionary and tableValueKeys to insert the values
    __block BOOL success = NO;
    [localQueue inDatabase:^(FMDatabase *localDatabase) {
        success = [localDatabase executeUpdate:sql withParameterDictionary:libraryObject.attributes];
        
        if (localDatabase.hadError) {
            DDLogCError(@"%@: Failed to put library object into local database. Error: %@", NSStringFromClass(self.class), localDatabase.lastError);
            [[NSException exceptionWithName:@"SQLiteException" reason:@"SQLite failed to put library object into the table." userInfo:nil] raise];
        }
    }];
    
    return success;
}

- (BOOL)updateLibraryObject:(LibraryObject *)libraryObject
                  IntoTable:(NSString *)tableName
{
    if (![tableName isEqualToString:[SampleConstants tableName]] && ![tableName isEqualToString:[SplitConstants tableName]]) {
        DDLogCError(@"%@: Invalid table name. Use the SampleConstants or SplitConstants tableName.", NSStringFromClass(self.class));
        return NO;
    }
    LibraryObject *oldObject = [self getLibraryObjectForKey:libraryObject.key FromTable:tableName];
    if (!oldObject) {
        DDLogCError(@"%@: Cannot update non-existent object!", NSStringFromClass(self.class));
        return NO;
    }
    
    NSArray *attrKeys = [tableName isEqualToString:[SampleConstants tableName]] ? [SampleConstants attributeNames] : [SplitConstants attributeNames];
    NSString *setSql;
    
    // Build the sql command, only update attributes that have changed
    for (int i=0; i<attrKeys.count; i++) {
        NSString *attrValue = [libraryObject.attributes objectForKey:[attrKeys objectAtIndex:i]];
        NSString *oldAttrValue = [oldObject.attributes objectForKey:[attrKeys objectAtIndex:i]];
        
        // If somehow got set to nil, change to empty string
        if (!attrValue)
            attrValue = @"";
        
        if (![attrValue isEqualToString:oldAttrValue]) {
            if (!setSql)
                setSql = [NSString stringWithFormat:@"SET %@='%@'", [attrKeys objectAtIndex:i], attrValue];
            else
                setSql = [setSql stringByAppendingString:[NSString stringWithFormat:@", %@='%@'", [attrKeys objectAtIndex:i], attrValue]];
        }
    }
    
    // No attributes have changed
    if (!setSql)
        return YES;
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE %@ %@ WHERE KEY='%@'", tableName, setSql, libraryObject.key];
    
    // Update the library object
    __block BOOL isUpdated = NO;
    [localQueue inDatabase:^(FMDatabase *localDatabase) {
        isUpdated = [localDatabase executeUpdate:sql];
        
        if (localDatabase.hadError) {
            DDLogCError(@"%@: Failed to update library object in local database. Error: %@", NSStringFromClass(self.class), localDatabase.lastError);
            [[NSException exceptionWithName:@"SQLiteException" reason:@"SQLite failed to update the library object." userInfo:nil] raise];
        }
    }];
    
    return isUpdated;
}

- (BOOL)deleteLibraryObjectWithKey:(NSString *)key
                         FromTable:(NSString *)tableName
{
    if (![tableName isEqualToString:[SampleConstants tableName]] && ![tableName isEqualToString:[SplitConstants tableName]]) {
        DDLogCError(@"%@: Invalid table name. Use the SampleConstants or SplitConstants tableName.", NSStringFromClass(self.class));
        return NO;
    }
    if (![self libraryObjectExistsForKey:key FromTable:tableName]) {
        DDLogCError(@"%@: Library object attempting to delete does not exist in the local database", NSStringFromClass(self.class));
        return NO;
    }
    
    // Delete images, if any
    LibraryObject *obj = [self getLibraryObjectForKey:key FromTable:tableName];
    if ([obj.attributes.allKeys containsObject:SMP_IMAGES]) {
        [SampleImageUtils removeAllImagesForSample:(Sample *)obj
                                       inDataStore:self
                                      inImageStore:[SampleImageUtils defaultImageStore]];
    }
    
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE KEY='%@'", tableName, key];
    
    // Delete library object
    __block BOOL isDeleted = NO;
    [localQueue inDatabase:^(FMDatabase *localDatabase) {
        isDeleted = [localDatabase executeUpdate:sql];
        
        if (localDatabase.hadError) {
            DDLogCError(@"%@: Failed to delete library object from local database. Error: %@", NSStringFromClass(self.class), localDatabase.lastError);
            [[NSException exceptionWithName:@"SQLiteException" reason:@"SQLite failed to delete the library object." userInfo:nil] raise];
        }
    }];
    
    if ([tableName isEqualToString:[SampleConstants tableName]]) {
        [self deleteAllSplitsForSampleKey:key];
    }
    
    return isDeleted;
}

- (BOOL)deleteAllSplitsForSampleKey:(NSString *)sampleKey
{
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@='%@'", [SplitConstants tableName], SPL_SAMPLE_KEY, sampleKey];
    
    // Delete splits with sampleKey
    __block BOOL isDeleted = NO;
    [localQueue inDatabase:^(FMDatabase *localDatabase) {
        isDeleted = [localDatabase executeUpdate:sql];
        
        if (localDatabase.hadError) {
            DDLogCError(@"%@: Failed to delete splits with sampleKey. Error: %@", NSStringFromClass(self.class), localDatabase.lastError);
            [[NSException exceptionWithName:@"SQLiteException" reason:@"SQLite failed to delete all splits for the sample key." userInfo:nil] raise];
        }
    }];
    
    return isDeleted;
}

- (BOOL)libraryObjectExistsForKey:(NSString *)key
                        FromTable:(NSString *)tableName
{
    if (![tableName isEqualToString:[SampleConstants tableName]] && ![tableName isEqualToString:[SplitConstants tableName]]) {
        DDLogCError(@"%@: Invalid table name. Use the SampleConstants or SplitConstants tableName.", NSStringFromClass(self.class));
        return NO;
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE KEY='%@'", tableName, key];
    
    // Check library object for key
    __block BOOL objectExists = NO;
    [localQueue inDatabase:^(FMDatabase *localDatabase) {
        FMResultSet *results = [localDatabase executeQuery:sql];
        
        if (localDatabase.hadError) {
            DDLogCError(@"%@: Failed to get library object from local database. Error: %@", NSStringFromClass(self.class), localDatabase.lastError);
            [[NSException exceptionWithName:@"SQLiteException" reason:@"SQLite failed to check if the library object existed for key." userInfo:nil] raise];
        }
        
        // Have the library object's attributes
        else if (results.next)
            objectExists = YES;
        [results close];
    }];
    
    return objectExists;
}

- (NSUInteger)countInTable:(NSString *)tableName
{
    if (![tableName isEqualToString:[SampleConstants tableName]] && ![tableName isEqualToString:[SplitConstants tableName]]) {
        DDLogCError(@"%@: Invalid table name. Use the SampleConstants or SplitConstants tableName.", NSStringFromClass(self.class));
        return 0;
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM %@", tableName];
    
    // Get the number of rows in table
    __block NSInteger count = 0;
    [localQueue inDatabase:^(FMDatabase *localDatabase) {
        FMResultSet *results = [localDatabase executeQuery:sql];
        
        if (localDatabase.hadError) {
            DDLogCError(@"%@: Failed to get count from local database. Error: %@", NSStringFromClass(self.class), localDatabase.lastError);
            [[NSException exceptionWithName:@"SQLiteException" reason:@"SQLite failed to count the number of objects in the table." userInfo:nil] raise];
        }
        
        // Have the library object's attributes
        else if (results.next)
            count = [[results.resultDictionary objectForKey:@"count(*)"] integerValue];
        [results close];
    }];
    
    return count;
}

- (void)setupTables
{
    [localQueue inDeferredTransaction:^(FMDatabase *localDatabase, BOOL *rollback) {
        // Create sample table
        [localDatabase executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@)", [SampleConstants tableName], [SampleConstants tableSchema]]];
        if (localDatabase.hadError) {
            DDLogCError(@"%@: Failed to create the sample table. Error: %@", NSStringFromClass(self.class), localDatabase.lastError);
            *rollback = YES;
            [[NSException exceptionWithName:@"SQLiteException" reason:@"SQLite failed to create the sample table." userInfo:nil] raise];
        }
        
        // Create split table
        [localDatabase executeUpdate:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@)", [SplitConstants tableName], [SplitConstants tableSchema]]];
        if (localDatabase.hadError) {
            DDLogCError(@"%@: Failed to create the split table. Error: %@", NSStringFromClass(self.class), localDatabase.lastError);
            *rollback = YES;
            [[NSException exceptionWithName:@"SQLiteException" reason:@"SQLite failed to create the split table." userInfo:nil] raise];
        }
    }];
}

@end
