//
//  DKNetworkingTool.h
//  TestNetworking
//
//  Created by 杜宇 on 2018/12/18.
//  Copyright © 2018 杜宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SuccessBlock)(NSDictionary * requestDic,NSString * msg);
typedef void(^ErrorBlock)(NSString *errorInfo);
typedef void(^loadProgress)(NSProgress *progress);

@interface DKNetworkingTool : NSObject

/**
  *  POST请求
  *
  *  @param urlStr      url
  *  @param parameters  post参数
  *  @param isCache     是否需要缓存
  *  @param success     成功的回调
  *  @param failure     失败的回调
  */
+ (void)postRequestURLStr:(NSString *)urlStr
               parameters:(id)parameters
                  isCache:(BOOL)isCache
                  success:(SuccessBlock)success
                  failure:(ErrorBlock)failure;


/**
  *  GET请求
  *
  *  @param urlStr  url
  *  @param isCache 是否需要缓存
  *  @param success 成功的回调
  *  @param failure 失败的回调
 */
+ (void)getRequestURLStr:(NSString *)urlStr
                 isCache:(BOOL)isCache
                 success:(SuccessBlock)success
                 failure:(ErrorBlock)failure;

#pragma mark --  上传单个文件
/**
 上传单个文件

 @param urlStr       服务器地址
 @param pasameters   参数
 @param attach       上传文件的 key
 @param data         上传的文件
 @param loadProgress 上传进度
 @param success      成功的回调
 @param failure      失败的回调
 */
+ (void)uploadDataWithURLStr:(NSString *)urlStr
                  parameters:(id)pasameters
                    imageKey:(NSString *)attach
                    withData:(NSData *)data
              uploadProgress:(loadProgress)loadProgress
                     success:(SuccessBlock)success
                     failure:(ErrorBlock)failure;


#pragma mark ---
#pragma mark ---   计算一共缓存的数据的大小
+ (NSString *)cacheSize;

#pragma mark ---
#pragma mark ---   清空缓存的数据
+ (void)deleateCache;

/**
 *  获取文件大小
 *
 *  @param path 本地路径
 *
 *  @return 文件大小
 */
+ (unsigned long long)fileSizeForPath:(NSString *)path;

@end

// 解决NSURLSession循环引用的问题
@interface AFManager : AFHTTPSessionManager

+ (AFHTTPSessionManager *)shareManager;

@end

NS_ASSUME_NONNULL_END
