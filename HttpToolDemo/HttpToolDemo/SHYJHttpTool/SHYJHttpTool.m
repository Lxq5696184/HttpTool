//
//  HttpTool.m
//  HttpToolDemo
//
//  Created by VinDiesel on 2019/7/24.
//  Copyright © 2019 jieyi. All rights reserved.
//

#import "SHYJHttpTool.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "SHYJHttpTool+RequestManager.h"
#import "HTCacheManager.h"
#define HT_ERROR_IMFORMATION @"网络出现错误，请检查网络连接"
#define HT_ERROR [NSError errorWithDomain:@"com.hyq.YQNetworking.ErrorDomain" code:-999 userInfo:@{ NSLocalizedDescriptionKey:HT_ERROR_IMFORMATION}]

static NSMutableArray * requestTaskPool;
static NSDictionary * headers;
static HttpToolNetworkStatus networkStatus;
static NSTimeInterval requestTimeout = 20.f;

@implementation SHYJHttpTool
#pragma mark - manager
+ (AFHTTPSessionManager *)manager {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    //默认解析模式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //配置请求序列化
    AFJSONResponseSerializer * serializer = [AFJSONResponseSerializer serializer];
    [serializer setRemovesKeysWithNullValues:YES];
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    manager.requestSerializer.timeoutInterval = requestTimeout;
    for (NSString * key in headers.allKeys) {
        if (headers[key] != nil) {
            [manager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
        }
    }
    //配置响应序列化
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*",
                                                                              @"application/octet-stream",
                                                                              @"application/zip"]];
    [self checkNetWworkStatus];
    return manager;
}
#pragma mark -- 检查网络
+ (void)checkNetWworkStatus {
    AFNetworkReachabilityManager * manager = [AFNetworkReachabilityManager manager];
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                networkStatus = HttpToolNetworkStatusUnknown;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                networkStatus = HttpToolNetworkStatusNotReachable;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                networkStatus = HttpToolNetworkStatusReachableViaWWAN;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                networkStatus = HttpToolNetworkStatusReachableViaWiFi;
                break;
            default:
                networkStatus = HttpToolNetworkStatusUnknown;
                break;
        }
    }];
}
+ (NSMutableArray *)allTasks {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (requestTaskPool == nil) {
            requestTaskPool = [NSMutableArray array];
        }
    });
    return  requestTaskPool;
}
#pragma mark - GET
+ (HTURLSessionTask *)getWithUrl:(NSString *)url
                  refreshRequest:(BOOL)refresh
                           cache:(BOOL)cache
                          params:(NSDictionary *)params
                   progressBlock:(HTGetProgress)progressBlock
                    successBlock:(HTSuccessBlock)successBlock
                       failBlock:(HTFailBlock)failBlock{
    //将session拷贝到堆中,block内部才可以获取到session
    __block HTURLSessionTask *session = nil;
    AFHTTPSessionManager *manager = [self manager];
    if (networkStatus == HttpToolNetworkStatusNotReachable) {
        if (failBlock) failBlock(HT_ERROR);
        return session;
    }
    id responseObj = [[HTCacheManager shareManager] getCacheResponseObjectWithRequestUrl:url params:params];
    if (responseObj && cache) {
        if (successBlock) {
            successBlock(responseObj);
        }
    }
    session = [manager GET:url parameters:params headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock(downloadProgress.completedUnitCount,
                          downloadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            successBlock(responseObject);
        }
        if (cache) {
            [[HTCacheManager shareManager] cacheResponseObject:responseObject requestUrl:url params:params];
        }
        [[self allTasks] removeObject:session];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failBlock) {
            failBlock(error);
        }
        [[self allTasks] removeObject:session];
    }];
    if ([self haveSameRequestInTasksPool:session] && !refresh) {
        //取消请求
        [session cancel];
        return  session;
    }else{
        //无论是否有旧请求,先执行取消旧请求,反正都需要刷新请求
        HTURLSessionTask * oldTask = [self cancelSameRequestTasksPool:session];
        if (oldTask) {
            [[self allTasks] removeObject:oldTask];
        }
        if (session) {
            [[self allTasks] addObject:session];
        }
        [session resume];
        return session;
    }
}
#pragma maek - post
+ (HTURLSessionTask *)postWithUrl:(NSString *)url
                   refreshRequest:(BOOL)refresh
                            cache:(BOOL)cache
                           params:(NSDictionary *)params
                    progressBlock:(HTGetProgress)progressBlock
                     successBlock:(HTSuccessBlock)successBlock
                        failBlock:(HTFailBlock)failBlock {
    
    __block HTURLSessionTask * session = nil;
    
    AFHTTPSessionManager * manager = [self manager];
    if (networkStatus == HttpToolNetworkStatusNotReachable) {
        if (failBlock) {
            failBlock(HT_ERROR);
            return session;
        }
    }
    id responseObj = [[HTCacheManager shareManager] getCacheResponseObjectWithRequestUrl:url params:params];
    if (responseObj && cache) {
        if (successBlock) {
            successBlock(responseObj);
        }
    }
    session = [manager POST:url parameters:params headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progressBlock) {
            progressBlock(uploadProgress.completedUnitCount,
                          uploadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            successBlock(responseObject);
        }
        if (cache) {
            [[HTCacheManager shareManager] cacheResponseObject:responseObject requestUrl:url params:params];
        }
        if ([[self allTasks] containsObject:session]) {
            [[self allTasks] removeObject:session];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failBlock) {
            failBlock(error);
        }
        [[self allTasks] removeObject:session];
    }];
    
    if ([self haveSameRequestInTasksPool:session] && !refresh) {
        [session cancel];
        return session;
    }else{
        HTURLSessionTask * oldTask = [self cancelSameRequestTasksPool:session];
        if (oldTask) {
            [[self allTasks] removeObject:oldTask];
        }
        if (session) {
            [[self allTasks] addObject:session];
        }
        [session resume];
        return session;
    }
}
#pragma mark -- JsonPost

+ (HTURLSessionTask *)jsonpostWithUrl:(NSString *)url
                       refreshRequest:(BOOL)refresh
                                cache:(BOOL)cache
                              params:(NSDictionary *)params
                        progressBlock:(HTGetProgress)progressBlock
                         successBlock:(HTSuccessBlock)successBlock
                            failBlock:(HTFailBlock)failBlock {
    __block HTURLSessionTask * session = nil;

    AFHTTPSessionManager * manager = [self manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    if (networkStatus == HttpToolNetworkStatusNotReachable) {
        if (failBlock) {
            failBlock(HT_ERROR);
            return session;
        }
    }
    id responseObj = [[HTCacheManager shareManager] getCacheResponseObjectWithRequestUrl:url params:params];
    if (responseObj && cache) {
        if (successBlock) {
            successBlock(responseObj);
        }
    }
    session = [manager POST:url parameters:params headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progressBlock) {
            progressBlock(uploadProgress.completedUnitCount,
                          uploadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            successBlock(responseObject);
        }
        if (cache) {
            [[HTCacheManager shareManager] cacheResponseObject:responseObject requestUrl:url params:params];
        }
        if ([[self allTasks] containsObject:session]) {
            [[self allTasks] removeObject:session];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failBlock) {
            failBlock(error);
        }
        [[self allTasks] removeObject:session];
    }];

    if ([self haveSameRequestInTasksPool:session] && !refresh) {
        [session cancel];
        return session;
    }else{
        HTURLSessionTask * oldTask = [self cancelSameRequestTasksPool:session];
        if (oldTask) {
            [[self allTasks] removeObject:oldTask];
        }
        if (session) {
            [[self allTasks] addObject:session];
        }
        [session resume];
        return session;
    }
}

#pragma mark -- 文件上传
+ (HTURLSessionTask *)uploadWithUrl:(NSString *)url
                           fileData:(NSData *)data
                               type:(NSString *)type
                               name:(NSString *)name
                           mimeType:(NSString *)mimeType
                      progressBlock:(HTUploadProgress)progressBlock
                       successBlock:(HTSuccessBlock)successBlock
                          failBlock:(HTFailBlock)failBlock {
    __block HTURLSessionTask * session = nil;
    
    AFHTTPSessionManager * manager = [self manager];
    if (networkStatus == HttpToolNetworkStatusNotReachable) {
        if (failBlock) {
            failBlock(HT_ERROR);
            return session;
        }
    }
    session = [manager POST:url parameters:nil headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSString *fileName = nil;
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        
        NSString * day = [formatter stringFromDate:[NSDate date]];
        fileName = [NSString stringWithFormat:@"%@.%@",day,type];
        [formData appendPartWithFileData:data name:name fileName:fileName mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progressBlock) {
            progressBlock(uploadProgress.completedUnitCount,
                          uploadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            successBlock(responseObject);
        }
        [[self allTasks] removeObject:session];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failBlock) {
            failBlock(error);
        }
        [[self allTasks] removeObject:session];
    }];
    [session resume];
    if (session) {
        [[self allTasks] addObject:session];
    }
    return session;
}
#pragma mark -- 多文件上传
+ (HTURLSessionTask *)moreuploadWithUrl:(NSString *)url
                              fileDatas:(NSArray *)datas
                                   type:(NSString *)type
                                   name:(NSString *)name
                               mimeType:(NSString *)mimeTypes
                          progressBlock:(HTUploadProgress)progressBlock
                           successBlock:(HTMoreUploadSuccessBlock)successBlock
                              failBlock:(HTMoreUploadFailBlock)failBlock {
    
    if (networkStatus == HttpToolNetworkStatusNotReachable) {
        if (failBlock) {
            failBlock(@[HT_ERROR]);
            return nil;
        }
    }
    __block NSMutableArray * sessions = [NSMutableArray array];
    __block NSMutableArray * responses = [NSMutableArray array];
    __block NSMutableArray * failResponse = [NSMutableArray array];
    
    dispatch_group_t  uploadGroup = dispatch_group_create();
    NSUInteger count = datas.count;
    for (int i = 0; i < count; i++) {
        __block HTURLSessionTask * session = nil;
        dispatch_group_enter(uploadGroup);
        session = [self uploadWithUrl:url fileData:datas[i] type:type name:name mimeType:mimeTypes progressBlock:^(int64_t bytesWritten, int64_t totalBytes) {
            if (progressBlock) {
                progressBlock(bytesWritten,totalBytes);
            }
        } successBlock:^(id  _Nonnull response) {
            [responses addObject:response];
            dispatch_group_leave(uploadGroup);
            [sessions removeObject:session];
        } failBlock:^(NSError * _Nonnull error) {
            NSError * Error = [NSError errorWithDomain:url code:-999 userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"第%d次上传失败",i]}];
            [failResponse addObject:Error];
            dispatch_group_leave(uploadGroup);
            [sessions removeObject:session];
        }];
        [session resume];
        if (session) {
            [sessions addObject:session];
        }
    }
    [[self allTasks] addObjectsFromArray:sessions];
    dispatch_group_notify(uploadGroup, dispatch_get_main_queue(), ^{
        if (responses.count > 0) {
            if (successBlock) {
                successBlock([responses copy]);
                if (sessions.count > 0) {
                    [[self allTasks] removeObjectsInArray:sessions];
                }
            }
        }
        if (failResponse.count > 0) {
            if (failBlock) {
                failBlock([failResponse copy]);
                if (sessions.count > 0) {
                    [[self allTasks] removeObjectsInArray:sessions];
                }
            }
        }
    });
    return [sessions copy];
}
#pragma mark -- 下载
+ (HTURLSessionTask *)downloadWithurl:(NSString *)url
                        progressBlock:(HTDownloadProgress)progressBlock
                         successBlock:(HTDownloadSuccessBlock)successBlock
                            failBlock:(HTDownloadFailBlock)failBlock {
    
    NSString * type = nil;
    NSArray * subStringArr = nil;
    __block HTURLSessionTask * session = nil;
    NSURL * fileUrl = [[HTCacheManager shareManager] getDownloadDataFromCacheWithRequestUrl:url];
    if (fileUrl) {
        if (successBlock) {
            successBlock(fileUrl);
            return nil;
        }
    }
    if (url) {
        subStringArr = [url componentsSeparatedByString:@"."];
        if (subStringArr.count > 0) {
            type = subStringArr[subStringArr.count - 1];
        }
    }
    AFHTTPSessionManager * manager = [self manager];
    //响应内容序列化为二进制
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    session = [manager GET:url parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock(downloadProgress.completedUnitCount,
                          downloadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (successBlock) {
            NSData * dataObj = (NSData *)responseObject;
            [[HTCacheManager shareManager] storeDownloadData:dataObj requestUrl:url];
            NSURL * downFileUrl = [[HTCacheManager shareManager] getDownloadDataFromCacheWithRequestUrl:url];
            successBlock(downFileUrl);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failBlock) {
            failBlock(error);
        }
    }];
    [session resume];
    if (session) {
        [[self allTasks] addObject:session];
    }
    return session;
}

#pragma mark -- other method
+ (void)setupTimeout:(NSTimeInterval)timeout {
    requestTimeout = timeout;
}
+ (void)canaelAllRequest {
    @synchronized (self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(HTURLSessionTask* obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[HTURLSessionTask class]]) {
                [obj cancel];
            }
        }];
        [[self allTasks] removeAllObjects];
    }
}
+ (void)cancelRequestWithURL:(NSString *)url {
    if (!url) {
        return;
    }
    @synchronized (self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(HTURLSessionTask* obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[HTURLSessionTask class]]) {
                if ([obj.currentRequest.URL.absoluteString hasSuffix:url]) {
                    [obj cancel];
                    *stop = YES;
                }
            }
        }];
    }
}
+ (void)configHttpHeader:(NSDictionary *)httpHeader {
    headers = httpHeader;
}
+ (NSArray *)currentRunningTasks {
    return [[self allTasks] copy];
}
@end

@implementation SHYJHttpTool (cache)

+(NSUInteger)totalCacheSize {
    return [[HTCacheManager shareManager] totalCacheSize];
}
+ (NSUInteger)totalDownloadDataSize {
    return [[HTCacheManager shareManager] totalDownloadDataSize];
}
+ (void)clearDownloadData {
    [[HTCacheManager shareManager] clearDownloadData];
}
+ (NSString *)getDownDiretoryPath {
    return [[HTCacheManager shareManager] getDownloadDiretoryPath];
}

+ (NSString *)getCacheDiretoryPath {
    return [[HTCacheManager shareManager] getCacheDiretoryPath];
}
+ (void)clearTotalCache {
    [[HTCacheManager shareManager] clearTotalCache];
}
@end
