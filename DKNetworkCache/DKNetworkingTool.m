//
//  DKNetworkingTool.m
//  TestNetworking
//
//  Created by 杜宇 on 2018/12/18.
//  Copyright © 2018 杜宇. All rights reserved.
//

#import "DKNetworkingTool.h"
#import "FMDB.h"
#import "MJExtension.h"
#import "DKFMDBTool.h"

#ifdef DEBUG
#define MCLog(...) NSLog(__VA_ARGS__) //如果不需要打印数据，把这__  NSLog(__VA_ARGS__) ___注释了
#else
#define MCLog(...)
#endif

// 缓存请求数据库名称
#define KDBName      @"goyohol.sqlite"
#define KDBTabelName @"NetworkCache"
/*!
 *  缓存的策略：(如果 cacheTime == 0，将永久缓存数据) 也就是缓存的时间 以 秒 为单位计算
 *  分钟 ： 60
 *  小时 ： 60 * 60
 *  一天 ： 60 * 60 * 24
 *  星期 ： 60 * 60 * 24 * 7
 *  一月 ： 60 * 60 * 24 * 30
 *  一年 ： 60 * 60 * 24 * 365
 *  永远 ： 0
 */
static NSInteger const cacheTime = 0;

// 缓存路径  缓存到Caches目录  统一做计算缓存大小，以及删除缓存操作
// NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
#define cachePath  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

// 请求方式
typedef NS_ENUM(NSInteger, RequestType) {
    RequestTypeGet,
    RequestTypePost,
    RequestTypeUpLoad
};

@interface DKNetworkingTool ()
    
@end

@implementation DKNetworkingTool

#pragma mark -- POST请求
+ (void)postRequestURLStr:(NSString *)urlStr
               parameters:(nonnull id)parameters
                  isCache:(BOOL)isCache
                  success:(nonnull SuccessBlock)success
                  failure:(nonnull ErrorBlock)failure
{
    [[self alloc] requestWithUrl:urlStr parameters:parameters requsetType:RequestTypePost isCache:isCache imageKey:nil withData:nil loadProgress:^(NSProgress *progress) {
        
    } success:^(NSDictionary *responseObject,NSString * msg) {
        success(responseObject,msg);
    } failure:^(NSString *errorInfo) {
        failure(errorInfo);
    }];
}

#pragma mark -- GET请求
+ (void)getRequestURLStr:(NSString *)urlStr
                 isCache:(BOOL)isCache
                 success:(SuccessBlock)success
                 failure:(ErrorBlock)failure
{
    [[self alloc] requestWithUrl:urlStr parameters:nil requsetType:RequestTypeGet isCache:isCache imageKey:nil withData:nil loadProgress:^(NSProgress *progress) {
        
    } success:^(NSDictionary *responseObject,NSString * msg) {
        success(responseObject,msg);
    } failure:^(NSString *errorInfo) {
        failure(errorInfo);
    }];
}

#pragma mark -- 上传单个文件
+ (void)uploadDataWithURLStr:(NSString *)urlStr
                  parameters:(id)pasameters
                    imageKey:(NSString *)attach
                    withData:(NSData *)data
              uploadProgress:(loadProgress)loadProgress
                     success:(SuccessBlock)success
                     failure:(ErrorBlock)failure{
    [[self alloc] requestWithUrl:urlStr parameters:pasameters requsetType:RequestTypeUpLoad isCache:NO imageKey:attach withData:data loadProgress:^(NSProgress *progress) {
        
    } success:^(NSDictionary *responseObject,NSString * msg) {
        success(responseObject,msg);
    } failure:^(NSString *errorInfo) {
        failure(errorInfo);
    }];
}

#pragma mark -- 网络请求统一处理
- (void)requestWithUrl:(NSString *)url
            parameters:(id)parameters
           requsetType:(RequestType)requestType
               isCache:(BOOL)isCache
              imageKey:(NSString *)attach
              withData:(NSData *)data
          loadProgress:(loadProgress)loadProgress
               success:(SuccessBlock)success
               failure:(ErrorBlock)failure{
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]; // ios9
    // 模型转字典
    parameters = [parameters mj_keyValues];

    if (parameters) {
        parameters = @{@"data":[self dictionaryToJson:parameters]};
    }
    NSString * cacheUrl = [self urlDictToStringWithUrlStr:url WithDict:parameters];
    MCLog(@"请求类型--->%@\n请求URL--->%@",(requestType ==RequestTypeGet)?@"Get":@"POST",cacheUrl);
    NSData * cacheData;
    if (isCache) {
        cacheData = [self cachedDataWithUrl:cacheUrl];
        if(cacheData.length != 0){
            [self returnDataWithRequestData:cacheData Success:^(NSDictionary *requestDic, NSString *msg) {
                MCLog(@"缓存数据--->%@",requestDic);
                success(requestDic,msg);
            } failure:^(NSString *errorInfo) {
                failure(errorInfo);
            }];
        }
    }
    //请求前网络检查
    if(![self requestBeforeCheckNetWork]){
        failure(@"请检查网络");
        return;
    }
    AFHTTPSessionManager *  manager = [AFManager shareManager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",nil];
    [manager.requestSerializer setTimeoutInterval:10];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    if (requestType == RequestTypeGet) {
        [manager GET:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self dealwithResponseObject:responseObject cacheUrl:cacheUrl cacheData:cacheData isCache:isCache success:^(NSDictionary *responseObject,NSString * msg) {
                success(responseObject,msg);
            } failure:^(NSString *errorInfo) {
                failure(errorInfo);
            }];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(@"网络请求失败");
        }];
    }
    if (requestType == RequestTypePost) {
        [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self dealwithResponseObject:responseObject cacheUrl:cacheUrl cacheData:cacheData isCache:isCache success:^(NSDictionary *responseObject,NSString * msg) {
                success(responseObject,msg);
            } failure:^(NSString *errorInfo) {
                failure(errorInfo);
            }];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(@"网络请求失败");
        }];
    }
    if (requestType == RequestTypeUpLoad) {
        [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            // 给上传的文件命名
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
            NSString * fileName =[NSString stringWithFormat:@"%@.png",@(timeInterval)];
            //添加要上传的文件，此处为图片   1.
            //            NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"123.ipa" withExtension:nil];
            //            [formData appendPartWithFileURL:fileURL name:fileName error:NULL];
            //添加图片，并对其进行压缩（0.0为最大压缩率，1.0为最小压缩率）  2.
            [formData appendPartWithFileData:data name:attach fileName:fileName mimeType:@"image/png"];
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            loadProgress(uploadProgress);
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self dealwithResponseObject:responseObject cacheUrl:cacheUrl cacheData:cacheData isCache:NO success:^(NSDictionary *responseObject,NSString * msg) {
                success(responseObject,msg);
            } failure:^(NSString *errorInfo) {
                failure(errorInfo);
            }];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failure(@"网络请求失败");
            MCLog(@"上传文件发生错误--->%@", error);
        }];
    }
}

#pragma mark -- 统一处理请求到得数据
/**
 @param responseData 网络请求的数据
 @param cacheUrl 缓存的url标识
 @param cacheData 缓存的数据
 @param isCache 是否需要缓存
 @param success 成功回调
 @param failure 失败回调
 */
- (void)dealwithResponseObject:(NSData *)responseData
                      cacheUrl:(NSString *)cacheUrl
                     cacheData:(NSData *)cacheData
                       isCache:(BOOL)isCache
                       success:(SuccessBlock)success
                       failure:(ErrorBlock)failure{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;// 关闭网络指示器
    });
    NSString * dataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    dataString = [self deleteSpecialCodeWithStr:dataString];
    NSData *requstData=[dataString dataUsingEncoding:NSUTF8StringEncoding];
    if (isCache) {/**更新缓存数据*/
        [self saveData:requstData url:cacheUrl];
    }
    if (!isCache || ![cacheData isEqual:requstData]) {
        [self returnDataWithRequestData:requstData Success:^(NSDictionary *requestDic, NSString *msg) {
            MCLog(@"网络数据--->%@",requestDic);
            success(requestDic,msg);
        } failure:^(NSString *errorInfo) {
            failure(errorInfo);
        }];
    }
}

#pragma mark --根据返回的数据进行统一的格式处理  ----requestData 网络或者是缓存的数据----
- (void)returnDataWithRequestData:(NSData *)requestData Success:(SuccessBlock)success failure:(ErrorBlock)failure{
    id myResult = [NSJSONSerialization JSONObjectWithData:requestData options:NSJSONReadingMutableContainers error:nil];
    if ([myResult isKindOfClass:[NSDictionary  class]]) {
        NSDictionary *  requestDic = (NSDictionary *)myResult;
        NSString * succ = requestDic[@"result"];
        if (succ.integerValue == 0) {
            success(requestDic[@"data"],requestDic[@"message"]);
        }else{
            failure(requestDic[@"message"]);
        }
    }
}

#pragma mark -- 数据库实例
static FMDatabase *_db;
+ (void)initialize {
    // 创建数据库
    _db = [[DKFMDBTool shareTool] getDBWithDBName:KDBName];
    // 创建表及表结构
    [[DKFMDBTool shareTool] DataBase:_db createTable:KDBTabelName keyTypes:@{@"url":@"text",@"savetime":@"date",@"data":@"blob"}];
}

#pragma mark --通过请求参数去数据库中加载对应的数据
- (NSData *)cachedDataWithUrl:(NSString *)url{
    
    NSData * data = [[NSData alloc]init];
    NSArray *result = [[DKFMDBTool shareTool] AllInformationDataBase:_db selectKeyTypes:@{@"url":@"text",@"savetime":@"date",@"data":@"blob"} fromTable:KDBTabelName whereCondition:@{@"url":url}];
    if (result.count>0) {
        for (NSDictionary *cache in result) {
            NSTimeInterval timeInterval = -[cache[@"savetime"] timeIntervalSinceNow];
            if(timeInterval > cacheTime &&  cacheTime!= 0){
                MCLog(@"缓存的数据过期了");
            }else{
                data = cache[@"data"];
            }
        }
    }
    return data;
}

#pragma mark -- 缓存数据到数据库中
- (void)saveData:(NSData *)data url:(NSString *)url{
    
    NSArray *result = [[DKFMDBTool shareTool] AllInformationDataBase:_db selectKeyTypes:@{@"url":@"text",@"savetime":@"date",@"data":@"blob"} fromTable:KDBTabelName whereCondition:@{@"url":url}];
    if (result.count>0) {
        [[DKFMDBTool shareTool] DataBase:_db updateTable:KDBTabelName setKeyValues:@{@"savetime":[NSDate date],@"data":data} whereCondition:@{@"url":url}];
//        MCLog(@"URL:%@-----%@",url,res?@"数据更新成功":@"数据更新失败");
    } else {
        [[DKFMDBTool shareTool] DataBase:_db insertKeyValues:@{@"url":url,@"savetime":[NSDate date],@"data":data} intoTable:KDBTabelName];
    }
}

#pragma mark  请求前统一处理：如果是没有网络，则不论是GET请求还是POST请求，均无需继续处理
- (BOOL)requestBeforeCheckNetWork {
    struct sockaddr zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sa_len = sizeof(zeroAddress);
    zeroAddress.sa_family = AF_INET;
    SCNetworkReachabilityRef defaultRouteReachability =
    SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags =
    SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if (!didRetrieveFlags) {
        printf("Error. Count not recover network reachability flags\n");
        return NO;
    }
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    BOOL isNetworkEnable  =(isReachable && !needsConnection) ? YES : NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = isNetworkEnable;/*  网络指示器的状态： 有网络 ： 开  没有网络： 关  */
    });
    return isNetworkEnable;
}
#pragma mark ---   计算一共缓存的数据的大小
+ (NSString *)cacheSize{
    NSFileManager *mgr = [NSFileManager defaultManager];
    NSArray *subpaths = [mgr subpathsAtPath:cachePath];
    long long ttotalSize = 0;
    for (NSString *subpath in subpaths) {
        NSString *fullpath = [cachePath stringByAppendingPathComponent:subpath];
        BOOL dir = NO;
        [mgr fileExistsAtPath:fullpath isDirectory:&dir];
        if (dir == NO) {// 文件
            ttotalSize += [[mgr attributesOfItemAtPath:fullpath error:nil][NSFileSize] longLongValue];
        }
    }//  M
    ttotalSize = ttotalSize/1024;
    return ttotalSize<1024?[NSString stringWithFormat:@"%lld KB",ttotalSize]:[NSString stringWithFormat:@"%.2lld MB",ttotalSize/1024];
}
/**
 *  获取文件大小
 */
+ (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}
#pragma mark ---   清空缓存的数据
+ (void)deleateCache{
    NSFileManager *mgr = [NSFileManager defaultManager];
    [mgr removeItemAtPath:cachePath error:nil];
}
#pragma mark -- 拼接 post 请求的网址
- (NSString *)urlDictToStringWithUrlStr:(NSString *)urlStr WithDict:(NSDictionary *)parameters{
    if (!parameters) {
        return urlStr;
    }
    NSMutableArray *parts = [NSMutableArray array];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id<NSObject> obj, BOOL *stop) {
        NSString *encodedKey = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *encodedValue = [obj.description stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSString *part = [NSString stringWithFormat: @"%@=%@", encodedKey, encodedValue];
        [parts addObject: part];
    }];
    NSString *queryString = [parts componentsJoinedByString: @"&"];
    queryString =  queryString ? [NSString stringWithFormat:@"?%@", queryString] : @"";
    NSString * pathStr =[NSString stringWithFormat:@"%@?%@",urlStr,queryString];
    return pathStr;
}
#pragma mark -- 处理json格式的字符串中的换行符、回车符
- (NSString *)deleteSpecialCodeWithStr:(NSString *)str {
    NSString *string = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@")" withString:@""];
    return string;
}

// Dictionary转jsonStr
- (NSString*)dictionaryToJson:(NSDictionary *)dic;
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end

@implementation AFManager

+ (AFHTTPSessionManager *)shareManager {
    static AFHTTPSessionManager *manager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
    });
    return manager;
}

@end
