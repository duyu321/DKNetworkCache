//
//  SaveDataTools.h
//  TestNetworking
//
//  Created by 杜宇 on 2018/12/20.
//  Copyright © 2018 杜宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface DKFMDBTool : NSObject
/**
 *  可以存储数据类型  text  integer  blob  boolean  date
 *  keyTypes      存储的字段  以及对应数据类型
 *  keyValues     存储的字段  以及对应的值
 */


/**
 *  数据库工具单例
 *
 *  @return 数据库工具对象
 */
+ (DKFMDBTool *)shareTool;

/**
 *  创建数据库
 *
 *  @param dbName 数据库名称(带后缀.sqlite)
 */
- (FMDatabase *)getDBWithDBName:(NSString *)dbName;

/**
 *  给指定数据库建表
 *
 *  @param db        指定数据库对象
 *  @param tableName 表的名称
 *  @param keyTypes   所含字段以及对应字段类型 字典
 */
- (void)DataBase:(FMDatabase *)db createTable:(NSString *)tableName keyTypes:(NSDictionary *)keyTypes;

/**
 *  给指定数据库的表添加值
 *
 *  @param db        数据库名称
 *  @param keyValues 字段及对应的值
 *  @param tableName 表名
 */
- (void)DataBase:(FMDatabase *)db insertKeyValues:(NSDictionary *)keyValues intoTable:(NSString *)tableName;

/**
 *  给指定数据库的表更新值
 *
 *  @param db        数据库名称
 *  @param keyValues 要更新字段及对应的值
 *  @param tableName 表名
 */
- (void)DataBase:(FMDatabase *)db updateTable:(NSString *)tableName setKeyValues:(NSDictionary *)keyValues;

/**
 *  条件更新
 *
 *  @param db        数据库名称
 *  @param tableName 表名称
 *  @param keyValues 要更新的字段及对应值
 *  @param condition 条件字典
 */
- (BOOL)DataBase:(FMDatabase *)db updateTable:(NSString *)tableName setKeyValues:(NSDictionary *)keyValues whereCondition:(NSDictionary *)condition;

#pragma mark --顺序查询 数据库表中的所有值（无限制全部 ⭐️升序⭐️）
/**
 *    按条件查询
 *
 *    @param db        数据库名称
 *    @param keyTypes  表名称
 *    @param tableName 要更新的字段及对应值
 *    @param colunm    要查询的类型  (顺序查询)
 *
 *    @return  数组
 */
- (NSArray *)SortAllInformationDataBase:(FMDatabase *)db selectKeyTypes:(NSDictionary *)keyTypes fromTable:(NSString *)tableName colunm:(NSString *)colunm;

#pragma mark --查询数据库表中的所有值（无限制全部）
/**
 *    按条件查询所有数据
 *
 *    @param db        数据库名称
 *    @param keyTypes  字典{数据格式及名称}
 *    @param tableName 表名
 *
 *    @return 数据返回数组
 */
- (NSArray *)AllInformationDataBase:(FMDatabase *)db selectKeyTypes:(NSDictionary *)keyTypes fromTable:(NSString *)tableName;

//按条件
- (NSArray *)AllInformationDataBase:(FMDatabase *)db selectKeyTypes:(NSDictionary *)keyTypes fromTable:(NSString *)tableName whereCondition:(NSDictionary *)condition;

/**
 *  查询数据库表中的所有值 限制数据条数10
 *
 *  @param db        数据库名称
 *  @param keyTypes 查询字段以及对应字段类型 字典
 *  @param tableName 表名称
 *  @return 查询得到数据
 */
- (NSArray *)DataBase:(FMDatabase *)db selectKeyTypes:(NSDictionary *)keyTypes fromTable:(NSString *)tableName;

/**
 *  条件查询数据库中的数据 限制数据条数10
 *
 *  @param db        数据库名称
 *  @param keyTypes 查询字段以及对应字段类型 字典
 *  @param tableName 表名称
 *  @param condition 条件
 *
 *  @return 查询得到数据 限制数据条数10
 */
- (NSArray *)DataBase:(FMDatabase *)db selectKeyTypes:(NSDictionary *)keyTypes fromTable:(NSString *)tableName whereCondition:(NSDictionary *)condition;


/**
 *  模糊查询 某字段以指定字符串开头的数据 限制数据条数10
 *
 *  @param db        数据库名称
 *  @param keyTypes 查询字段以及对应字段类型 字典
 *  @param tableName 表名称
 *  @param key       条件字段
 *  @param str       开头字符串
 *
 *  @return 查询所得数据 限制数据条数10
 */
- (NSArray *)DataBase:(FMDatabase *)db selectKeyTypes:(NSDictionary *)keyTypes fromTable:(NSString *)tableName whereKey:(NSString *)key beginWithStr:(NSString *)str;

/**
 *  模糊查询 某字段包含指定字符串的数据 限制数据条数10
 *
 *  @param db        数据库名称
 *  @param keyTypes 查询字段以及对应字段类型 字典
 *  @param tableName 表名称
 *  @param key       条件字段
 *  @param str       所包含的字符串
 *
 *  @return 查询所得数据
 */
- (NSArray *)DataBase:(FMDatabase *)db selectKeyTypes:(NSDictionary *)keyTypes fromTable:(NSString *)tableName whereKey:(NSString *)key containStr:(NSString *)str;

/**
 *  模糊查询 某字段以指定字符串结尾的数据 限制数据条数10
 *
 *  @param db        数据库名称
 *  @param keyTypes 查询字段以及对应字段类型 字典
 *  @param tableName 表名称
 *  @param key       条件字段
 *  @param str       结尾字符串
 *
 *  @return 查询所得数据
 */
- (NSArray *)DataBase:(FMDatabase *)db selectKeyTypes:(NSDictionary *)keyTypes fromTable:(NSString *)tableName whereKey:(NSString *)key endWithStr:(NSString *)str;


#pragma mark - 清除

/**
 *  清理指定数据库中的数据  （只删除数据不删除数据库）
 *
 *  @param db 指定数据库
 */
- (void)clearDatabase:(FMDatabase *)db from:(NSString *)tableName;

/**
 *  删除表
 */
- (void)dropTableFormDatabase:(FMDatabase *)db table:(NSString *)tableName;

/**
 *  删除指定表(数据库) 中的 单条数据          (单一指定条件)
 */
- (void)deleteOneDataFormDatabase:(FMDatabase *)db fromTable:(NSString *)tableName whereConditon:(NSDictionary *)condition;


#pragma mark - 查询
/**
 *  特定条件查integer
 */
- (NSInteger)DHSelectIntegerWithDB:(FMDatabase *)db table:(NSString *)table colunm:(NSString *)colunm  whereCondition:(NSDictionary *)conditon;
/**
 *  特定条件查text
 */
- (NSString *)DHSelectTextWithDB:(FMDatabase *)db table:(NSString *)table colunm:(NSString *)colunm whereCondition:(NSDictionary *)condition;

/**
 *  通过特定条件返回data数据
 *  @param conditon 字典:@{@"某行":@"值"}
 *
 *  @return data
 */
- (NSData *)DHSelectDataWithDB:(FMDatabase *)db table:(NSString *)table colunm:(NSString *)colunm  whereCondition:(NSDictionary *)conditon;

#pragma mark - 更新
/**
 *  特定条件更新,注意：***条件只有一个键值对***
 */
- (BOOL)DHUpdateWithDB:(FMDatabase *)db table:(NSString *)table
           setKeyValue:(NSDictionary *)keyValue
             condition:(NSDictionary *)condition;

#pragma mark - 判断是否存在
/**
 *  判断有没有该字段
 */
- (BOOL)DHisExistObjectInDataBase:(FMDatabase *)db fromTable:(NSString *)tableName colunm:(NSString *)colunm identify:(NSString *)identify;

/**
 *  判断有没有该字段,多个条件的
 */
- (BOOL)DHisExistObjectInDataBase:(FMDatabase *)db fromTable:(NSString *)tableName condition:(NSDictionary *)condition;

/**
 *  判断有没表
 */
- (BOOL)DHisExistTable:(NSString *)tableName DataBase:(FMDatabase *)db;

#pragma mark - other
/**
 *  查找最后一行
 */
- (NSArray *)DHLastLineDataBase:(FMDatabase *)db fromTable:(NSString *)tableName colunm:(NSString *)colunm;

@end

NS_ASSUME_NONNULL_END
