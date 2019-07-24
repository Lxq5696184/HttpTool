//
//  HttpTool.h
//  HttpToolDemo
//
//  Created by VinDiesel on 2019/7/24.
//  Copyright © 2019 jieyi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
NS_ASSUME_NONNULL_BEGIN
/**
*网络状态
*/
typedef NS_ENUM(NSInteger,HttpToolNetworkStatus){
 
    /**
     * 未知网络
     */
    HttpToolNetworkStatusUnknown              = 1 << 0,
    /**
     * 无法连接
     */
    HttpToolNetworkStatusNotReachable         = 1 << 1,
    /**
     *WWAN网络
     */
    HttpToolNetworkStatusReachableViaWWAN     = 1 << 2,
    /**
     * WiFi网络
     */
    HttpToolNetworkStatusReachableViaWiFi     = 1 << 3
};
/**
 * 请求任务
 */
typedef NSURLSessionTask HTURLSessionTask;

/**
 *  请求成功回调
 *
 * @param response 成功后返回的数据
 */
typedef void(^HTSuccessBlock)(id response);
/**
 *  请求失败回调
 *
 *  @param error  失败返回的错误信息
*/
typedef void(^HTFailBlock)(NSError *error);
/**
 *下载进度
 *
 *@param bytesRead   已下载的大小
 *@param totalBytes  总下载大小
 */
typedef void(^HTDownloadProgress)(int64_t bytesRead, int64_t totalBytes);

/**
 *下载成功回调
 *
 *@param url     下载存放的路径
 */
typedef void(^HTDownloadSuccessBlock)(NSURL*url);
/**
 * 上传进度
 *
 * @param bytesWritten   已上传的大小
 * @param totalBytes     总上传的大小
 */
typedef void(^HTUploadProgress)(int64_t bytesWritten,int64_t totalBytes);

/**
 *多文件上传成功回调
 *
 *@param response 成功后返回的数据
 */
typedef void(^HTMoreUploadSuccessBlock)(NSArray*response);

/**
 *多文件上传失败回调
 *
 *@param errors   失败后返回的错误信息
 */
typedef void(^HTMoreUploadFailBlock)(NSArray *errors);

typedef HTDownloadProgress HTGetProgress;
typedef HTDownloadProgress HTPostProgress;
typedef HTFailBlock        HTDownloadFailBlock;

@interface SHYJHttpTool : NSObject
/**
 *正在运行的网络任务
 *
 *#param task
 */
+ (NSArray *)currentRunningTasks;
/**
 * 配置请求头
 *
 * @param httpHeader 请求头
 */
+ (void)configHttpHeader:(NSDictionary *)httpHeader;
/**
 * 取消GET请求
 */
+ (void)cancelRequestWithURL:(NSString *)url;
/**
 * 取消所有请求
 */
+ (void)canaelAllRequest;
/**
 * 设置超时时间
 *
 * @param timeout 超时时间
 */
+ (void)setupTimeout:(NSTimeInterval)timeout;
/**
 *  GET请求
 *
 *  @param url              请求路径
 *  @param cache            是否缓存
 *  @param refresh          是否刷新请求(遇到重复请求，若为YES，则会取消旧的请求，用新的请求，若为NO，则忽略新请求，用旧请求)
 *  @param params           拼接参数
 *  @param progressBlock    进度回调
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (HTURLSessionTask *)getWithUrl:(NSString *)url
                  refreshRequest:(BOOL)refresh
                           cache:(BOOL)cache
                          params:(NSDictionary *)params
                   progressBlock:(HTGetProgress)progressBlock
                    successBlock:(HTSuccessBlock)successBlock
                       failBlock:(HTFailBlock)failBlock;

/**
 *  POST请求
 *
 *  @param url              请求路径
 *  @param cache            是否缓存
 *  @param refresh          解释同上
 *  @param params           拼接参数
 *  @param progressBlock    进度回调
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (HTURLSessionTask *)postWithUrl:(NSString *)url
                  refreshRequest:(BOOL)refresh
                           cache:(BOOL)cache
                          params:(NSDictionary *)params
                   progressBlock:(HTGetProgress)progressBlock
                    successBlock:(HTSuccessBlock)successBlock
                       failBlock:(HTFailBlock)failBlock;

/**
 *  JSONPOST请求
 *
 *  @param url              请求路径
 *  @param cache            是否缓存
 *  @param refresh          解释同上
 *  @param params           参数
 *  @param progressBlock    进度回调
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (HTURLSessionTask *)jsonpostWithUrl:(NSString *)url
                   refreshRequest:(BOOL)refresh
                            cache:(BOOL)cache
                          params:(NSDictionary *)params
                    progressBlock:(HTGetProgress)progressBlock
                     successBlock:(HTSuccessBlock)successBlock
                        failBlock:(HTFailBlock)failBlock;


/**
 *  文件上传
 *
 *  @param url              上传文件接口地址
 *  @param data             上传文件数据
 *  @param type             上传文件类型
 *  @param name             上传文件服务器文件夹名
 *  @param mimeType         mimeType
 *  @param progressBlock    上传文件路径
 *    @param successBlock     成功回调
 *    @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (HTURLSessionTask *)uploadWithUrl:(NSString *)url
                           fileData:(NSData *)data
                               type:(NSString *)type
                               name:(NSString *)name
                           mimeType:(NSString *)mimeType
                      progressBlock:(HTUploadProgress)progressBlock
                       successBlock:(HTSuccessBlock)successBlock
                          failBlock:(HTFailBlock)failBlock;
/**
 *  多文件上传
 *
 *  @param url           上传文件地址
 *  @param datas         数据集合
 *  @param type          类型
 *  @param name          服务器文件夹名
 *  @param mimeTypes      mimeTypes
 *  @param progressBlock 上传进度
 *  @param successBlock  成功回调
 *  @param failBlock     失败回调
 *
 *  @return 任务集合
 */
+ (HTURLSessionTask *)moreuploadWithUrl:(NSString *)url
                           fileDatas:(NSArray *)datas
                               type:(NSString *)type
                               name:(NSString *)name
                           mimeType:(NSString *)mimeTypes
                      progressBlock:(HTUploadProgress)progressBlock
                       successBlock:(HTMoreUploadSuccessBlock)successBlock
                          failBlock:(HTMoreUploadFailBlock)failBlock;
/**
 *  文件下载
 *
 *  @param url           下载文件接口地址
 *  @param progressBlock 下载进度
 *  @param successBlock  成功回调
 *  @param failBlock     下载回调
 *
 *  @return 返回的对象可取消请求
 */
+ (HTURLSessionTask *)downloadWithurl:(NSString *)url
                        progressBlock:(HTDownloadProgress)progressBlock
                         successBlock:(HTDownloadSuccessBlock)successBlock
                            failBlock:(HTDownloadFailBlock)failBlock;
@end
@interface SHYJHttpTool (cache)
/**
 * 获取缓存目录路径
 *
 *@return 缓存目录路径
 */
+ (NSString *)getCacheDiretoryPath;

/**
 * 获取下载目录路径
 *
 * @return 下载目录路径
 */
+ (NSString *)getDownDiretoryPath;

/**
 * 获取缓存大小
 *
 * @return 缓存大小
 */
+ (NSUInteger)totalCacheSize;

/**
 *清楚所有缓存
 *
 */
+ (void)clearTotalCache;
/**
 *获取所有下载数据大小
 *
 * @return 下载数据大小
 */
+ (NSUInteger)totalDownloadDataSize;
/**
 *清楚下载数据
 */
+ (void)clearDownloadData;
@end

NS_ASSUME_NONNULL_END
