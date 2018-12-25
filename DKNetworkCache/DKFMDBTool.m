//
//  SaveDataTools.m
//  TestNetworking
//
//  Created by 杜宇 on 2018/12/20.
//  Copyright © 2018 杜宇. All rights reserved.
//

#import "DKFMDBTool.h"


static DKFMDBTool *tool = nil;

@implementation DKFMDBTool

+ (DKFMDBTool *)shareTool {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (tool == nil) {
            tool = [[self alloc] init];
        }
    });
    return tool;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (tool == nil) {
            tool = [super allocWithZone:zone];
        }
    });
    return tool;
}






#pragma mark --创建数据库
- (FMDatabase *)getDBWithDBName:(NSString *)dbName
{
    NSArray *library = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);// 沙盒路径
    NSString *dbPath = [library[0] stringByAppendingPathComponent:dbName];
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    NSLog(@"sqlite地址-->%@",dbPath);
    if (![db open]) {
        NSLog(@"无法获取数据库");
        return nil;
    }
    return db;
}

#pragma mark --给指定数据库建表
- (void)DataBase:(FMDatabase *)db createTable:(NSString *)tableName keyTypes:(NSDictionary *)keyTypes
{
    if ([self isOpenDatabese:db]) {
        NSMutableString *sql = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id integer primary key,",tableName]];
        int count = 0;
        for (NSString *key in keyTypes) {
            count++;
            [sql appendString:key];
            [sql appendString:@" "];
            [sql appendString:[keyTypes valueForKey:key]];
            if (count != [keyTypes count]) {
                [sql appendString:@", "];
            }
        }
        [sql appendString:@")"];
        [db executeUpdate:sql];
    }
}

#pragma mark --给指定数据库的表添加值
- (void)DataBase:(FMDatabase *)db insertKeyValues:(NSDictionary *)keyValues intoTable:(NSString *)tableName
{
    if ([self isOpenDatabese:db]) {
        
        NSArray *keys = [keyValues allKeys];
        NSArray *values = [keyValues allValues];
        NSMutableString *sql = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"INSERT INTO %@ (", tableName]];
        NSInteger count = 0;
        for (NSString *key in keys) {
            [sql appendString:key];
            count ++;
            if (count < [keys count]) {
                [sql appendString:@", "];
            }
        }
        [sql appendString:@") VALUES ("];
        for (int i = 0; i < [values count]; i++) {
            [sql appendString:@"?"];
            if (i < [values count] - 1) {
                [sql appendString:@","];
            }
        }
        [sql appendString:@")"];
        
        [db executeUpdate:sql withArgumentsInArray:values];
    }
}

#pragma mark --给指定数据库的表更新值
- (void)DataBase:(FMDatabase *)db updateTable:(NSString *)tableName setKeyValues:(NSDictionary *)keyValues
{
    if ([self isOpenDatabese:db]) {
        for (NSString *key in keyValues) {
            NSMutableString *sql = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"UPDATE %@ SET %@ = ?", tableName, key]];
            [db executeUpdate:sql,[keyValues valueForKey:key]];
        }
    }
}

#pragma mark --条件更新,跟新data
- (BOOL)DataBase:(FMDatabase *)db updateTable:(NSString *)tableName setKeyValues:(NSDictionary *)keyValues whereCondition:(NSDictionary *)condition
{
    BOOL isSuccess = NO;
    NSInteger count = [condition allKeys].count;
    
    if ([self isOpenDatabese:db]) {
        if (count == 1) {
            for (NSString *key in keyValues) {
                NSMutableString *sql = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"UPDATE %@ SET %@ = ? WHERE %@ = ?", tableName, key, [condition allKeys][0]]];
                isSuccess = [db executeUpdate:sql,[keyValues valueForKey:key],[condition valueForKey:[condition allKeys][0]]];
            }
        } else {
            for (NSString *key in keyValues) {
                int condition_count = 0;
                NSMutableArray *condition_valueArr = [NSMutableArray array];
                [condition_valueArr addObject:keyValues[key]];
                NSMutableString *sql = [NSMutableString stringWithFormat:@"update %@ set %@ = ? where ",tableName,key];
                for (NSString *condition_key in condition) {
                    condition_count ++;
                    if (condition_count == count) {
                        [sql appendFormat:@"%@ = ?",condition_key];
                    } else {
                        [sql appendFormat:@"%@ = ? and ",condition_key];
                    }
                    [condition_valueArr addObject:condition[condition_key]];
                }
                isSuccess = [db executeUpdate:sql withArgumentsInArray:condition_valueArr];
            }
        }
    }
    return isSuccess;
}



#pragma mark --顺序查询 数据库表中的所有值（无限制全部 ⭐️升序⭐️）
- (NSArray *)SortAllInformationDataBase:(FMDatabase *)db selectKeyTypes:(NSDictionary *)keyTypes fromTable:(NSString *)tableName colunm:(NSString *)colunm
{
    FMResultSet *result =  [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ ASC",tableName,colunm] ];
    NSLog(@"---->%@",[NSString stringWithFormat:@"SELECT * FROM %@ sort",tableName]);
    return [self getArrWithFMResultSet:result keyTypes:keyTypes];
}

#pragma mark --查询数据库表中的所有值（⭐️无限制全部）
- (NSArray *)AllInformationDataBase:(FMDatabase *)db selectKeyTypes:(NSDictionary *)keyTypes fromTable:(NSString *)tableName
{
    FMResultSet *result =  [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@",tableName]];
    NSLog(@"---->%@",[NSString stringWithFormat:@"SELECT * FROM %@",tableName]);
    return [self getArrWithFMResultSet:result keyTypes:keyTypes];
}

#pragma mark --条件查询数据库中 所有的数据   （无限制全部）
- (NSArray *)AllInformationDataBase:(FMDatabase *)db selectKeyTypes:(NSDictionary *)keyTypes fromTable:(NSString *)tableName whereCondition:(NSDictionary *)condition
{
    if ([self isOpenDatabese:db]) {
        
        FMResultSet *result =  [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ?",tableName, [condition allKeys][0]], [condition valueForKey:[condition allKeys][0]]];
        return [self getArrWithFMResultSet:result keyTypes:keyTypes];
    }else
        return nil;
}





#pragma mark --查询数据库表中的所有值  (限制数据条数:10)
- (NSArray *)DataBase:(FMDatabase *)db selectKeyTypes:(NSDictionary *)keyTypes fromTable:(NSString *)tableName
{
    FMResultSet *result =  [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ LIMIT 10",tableName]];
    NSLog(@"---->%@",[NSString stringWithFormat:@"SELECT * FROM %@ LIMIT 10",tableName]);
    return [self getArrWithFMResultSet:result keyTypes:keyTypes];
}

#pragma mark --条件查询数据库中的数据  (限制数据条数:10)
- (NSArray *)DataBase:(FMDatabase *)db selectKeyTypes:(NSDictionary *)keyTypes fromTable:(NSString *)tableName whereCondition:(NSDictionary *)condition;
{
    if ([self isOpenDatabese:db]) {
        
        FMResultSet *result =  [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = ? LIMIT 10",tableName, [condition allKeys][0]], [condition valueForKey:[condition allKeys][0]]];
        return [self getArrWithFMResultSet:result keyTypes:keyTypes];
    }else
        return nil;
}



#pragma mark --模糊查询 某字段以⭐️指定字符串  开头⭐️的数据  (限制数据条数:10)
- (NSArray *)DataBase:(FMDatabase *)db selectKeyTypes:(NSDictionary *)keyTypes fromTable:(NSString *)tableName whereKey:(NSString *)key beginWithStr:(NSString *)str
{
    if ([self isOpenDatabese:db]) {
        FMResultSet *result =  [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ LIKE %@%% LIMIT 10",tableName, key, str]];
        return [self getArrWithFMResultSet:result keyTypes:keyTypes];
    }else
        return nil;
}

#pragma mark --模糊查询 某字段 ⭐️包含⭐️指定字符串的数据  (限制数据条数:10)
- (NSArray *)DataBase:(FMDatabase *)db selectKeyTypes:(NSDictionary *)keyTypes fromTable:(NSString *)tableName whereKey:(NSString *)key containStr:(NSString *)str
{
    if ([self isOpenDatabese:db]) {
        
        FMResultSet *result =  [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ LIKE %%%@%% LIMIT 10",tableName, key, str]];
        return [self getArrWithFMResultSet:result keyTypes:keyTypes];
    }else
        return nil;
}

#pragma mark --模糊查询 某字段以指定字符串⭐️结尾⭐️的数据  (限制数据条数:10)
- (NSArray *)DataBase:(FMDatabase *)db selectKeyTypes:(NSDictionary *)keyTypes fromTable:(NSString *)tableName whereKey:(NSString *)key endWithStr:(NSString *)str
{
    if ([self isOpenDatabese:db]) {
        FMResultSet *result =  [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE %@ LIKE %%%@ LIMIT 10",tableName, key, str]];
        return [self getArrWithFMResultSet:result keyTypes:keyTypes];
    }else
        return nil;
}


#pragma mark --清理指定数据库中 表里的数据
- (void)clearDatabase:(FMDatabase *)db from:(NSString *)tableName
{
    if ([self isOpenDatabese:db]) {
        [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@",tableName]];
    }
}

#pragma mark --删除指定数据库中的 表
- (void)dropTableFormDatabase:(FMDatabase *)db table:(NSString *)tableName
{
    if ([self isOpenDatabese:db]) {
        [db executeUpdate:[NSString stringWithFormat:@"DROP TABLE '%@'",tableName]];
    }
}

#pragma mark --(单一指定条件)删除指定数据库、表 中的 单条数据
- (void)deleteOneDataFormDatabase:(FMDatabase *)db fromTable:(NSString *)tableName whereConditon:(NSDictionary *)condition
{
    if ([self isOpenDatabese:db]) {
        [db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@='%@';",tableName,[condition allKeys][0],    [condition allValues][0]]];
    }
}



#pragma mark - 查询语句          (1000条数据)
/**
 *  特定条件查integer
 */
- (NSInteger)DHSelectIntegerWithDB:(FMDatabase *)db table:(NSString *)table colunm:(NSString *)colunm  whereCondition:(NSDictionary *)condition {
    
    NSInteger result = 0;
    if ([self isOpenDatabese:db]) {
        NSString *sql = [NSString stringWithFormat:@"select %@ from %@  WHERE  %@ = '%@' limit 0,1000",colunm,table,[condition allKeys][0],[condition allValues][0]];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            result = [rs intForColumn:colunm];
        }
    }
    return result;
}
/**
 *  特定条件查text
 */
- (NSString *)DHSelectTextWithDB:(FMDatabase *)db table:(NSString *)table colunm:(NSString *)colunm whereCondition:(NSDictionary *)condition {
    
    NSString *result_str;
    if ([self isOpenDatabese:db]) {
        NSString *sql = [NSString stringWithFormat:@"select %@ from %@  WHERE  %@ = '%@' limit 0,1000",colunm,table,[condition allKeys][0],[condition allValues][0]];
        FMResultSet *rs = [db executeQuery:sql];
        while ([rs next]) {
            return [rs stringForColumn:colunm];
        }
    }
    return result_str;
}
/**
 *  特定条件查data
 */
- (NSData *)DHSelectDataWithDB:(FMDatabase *)db table:(NSString *)table colunm:(NSString *)colunm  whereCondition:(NSDictionary *)conditon {
    
    if ([self isOpenDatabese:db]) {
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select %@ from %@  WHERE  %@ = '%@' limit 0,1000",colunm,table,[conditon allKeys][0],[conditon allValues][0]]];
        while ([rs next]) {
            NSData *data = [rs dataForColumn:colunm];
            return data;
        }
    }
    return nil;
}




#pragma mark - update
/**
 *  特定条件更新                 注意：***条件只有一个键值对,最好用上面那个***
 *                             而且还只能是字符串之类
 */
- (BOOL)DHUpdateWithDB:(FMDatabase *)db table:(NSString *)table
           setKeyValue:(NSDictionary *)keyValue
             condition:(NSDictionary *)condition
{
    BOOL isSuccess = false;
    NSArray *keys = [keyValue allKeys];
    if ([self isOpenDatabese:db]) {
        NSMutableString *sql = [NSMutableString stringWithFormat:@"update %@ set ",table];
        int count = 0;
        for (NSString *key in keyValue) {
            count ++;
            count == keys.count ? [sql appendFormat:@"%@ = '%@' ",key,keyValue[key]] : [sql appendFormat:@"%@ = '%@',",key,keyValue[key]];
        }
        [sql appendFormat:@"where %@ = '%@'",[condition allKeys][0],[condition allValues][0]];
        
        isSuccess = [db executeUpdate:sql];
    }
    
    return isSuccess;
}



#pragma mark - 判断是否存在
/**
 *  判断 有没有 该字段
 */
- (BOOL)DHisExistObjectInDataBase:(FMDatabase *)db fromTable:(NSString *)tableName colunm:(NSString *)colunm identify:(NSString *)identify
{
    if ([self isOpenDatabese:db]) {
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select count(1) from %@ where %@ = '%@'",tableName,colunm,identify]];
        int a = 0;
        while ([rs next]) {
            a = [rs intForColumn:@"count(1)"];
        }
        return a > 0 ? YES : NO;
    }else
        return NO;
}

/**
 *  判断有没有该字段,多个条件的
 */
- (BOOL)DHisExistObjectInDataBase:(FMDatabase *)db fromTable:(NSString *)tableName condition:(NSDictionary *)condition {
    
    NSArray *keys = [condition allKeys];
    int count = 0;
    if ([self isOpenDatabese:db]) {
        NSMutableString *sql = [NSMutableString stringWithFormat:@"select count(1) from %@ where ",tableName];
        for (NSString *key in condition) {
            count ++;
            [sql appendString:(count == keys.count ? [NSString stringWithFormat:@"%@ = '%@'",key,condition[key]] : [NSString stringWithFormat:@"%@ = '%@' AND ",key,condition[key]])];
        }
        FMResultSet *rs = [db executeQuery:sql];
        int a = 0;
        while ([rs next]) {
            a = [rs intForColumn:@"count(1)"];
        }
        return a > 0 ? YES : NO;
    }
    return NO;
}

/**
 *  判断表的存在
 */
- (BOOL)DHisExistTable:(NSString *)tableName DataBase:(FMDatabase *)db
{
    FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    while ([rs next])
    {
        // just print out what we've got in a number of formats.
        NSInteger count = [rs intForColumn:@"count"];
        //        NSLog(@"isTableOK %d", count);
        if (0 == count)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    return NO;
}




/**
 *  (获取)查找最后一行
 */
- (NSArray *)DHLastLineDataBase:(FMDatabase *)db fromTable:(NSString *)tableName colunm:(NSString *)colunm
{
    if ([self isOpenDatabese:db]) {
        FMResultSet *result =  [db executeQuery:[NSString stringWithFormat:@"select %@ from %@ order by %@ desc limit 1",colunm,tableName,colunm]];
        return [self getArrWithFMResultSet:result keyTypes:@{colunm:@"text"}];
    }else
        return nil;
}


















// 私有方法
#pragma mark -- CommonMethod   确定类型
- (NSArray *)getArrWithFMResultSet:(FMResultSet *)result keyTypes:(NSDictionary *)keyTypes
{
    NSMutableArray *tempArr = [NSMutableArray array];
    while ([result next]) {
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        for (int i = 0; i < keyTypes.count; i++) {
            NSString *key = [keyTypes allKeys][i];
            NSString *value = [keyTypes valueForKey:key];
            if ([value isEqualToString:@"text"] || [value isEqualToString:@"TEXT"]) {
                //                字符串
                [tempDic setValue:[result stringForColumn:key] forKey:key];
            }else if([value isEqualToString:@"blob"] || [value isEqualToString:@"BLOB"])
            {
                //                二进制对象
                [tempDic setValue:[result dataForColumn:key] forKey:key];
            }else if ([value isEqualToString:@"integer"] || [value isEqualToString:@"INTEGER"])
            {
                //                带符号整数类型
                [tempDic setValue:[NSNumber numberWithInt:[result intForColumn:key]]forKey:key];
            }else if ([value isEqualToString:@"boolean"] || [value isEqualToString:@"BOOLLEAN"])
            {
                //                BOOL型
                [tempDic setValue:[NSNumber numberWithBool:[result boolForColumn:key]] forKey:key];
            }else if ([value isEqualToString:@"date"] || [value isEqualToString:@"DATE"])
            {
                //                date
                [tempDic setValue:[result dateForColumn:key] forKey:key];
            }
        }
        [tempArr addObject:tempDic];
    }
    return tempArr;
}

#pragma mark -- 数据库 是否已经 打开
-(BOOL)isOpenDatabese:(FMDatabase *)db
{
    if (![db open]) {
        [db open];
    }
    return YES;
}

@end
