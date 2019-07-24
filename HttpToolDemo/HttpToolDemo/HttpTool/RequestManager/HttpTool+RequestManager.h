//
//  HttpTool+RequestManager.h
//  HttpToolDemo
//
//  Created by VinDiesel on 2019/7/24.
//  Copyright © 2019 jieyi. All rights reserved.
//

#import "HttpTool.h"

NS_ASSUME_NONNULL_BEGIN

@interface HttpTool (RequestManager)
/**
 *  判断网络请求池中d是否有相同的请求
 *
 *  @param task 网络请求任务
 *
 *  @return bool
 */
+ (BOOL)haveSameRequestInTasksPool:(HTURLSessionTask *)task;

/**
 *  如果有旧请求则取消旧请求
 *
 *  @param task 新请求
 *
 *  @return 旧请求
 */
+ (HTURLSessionTask *)cancelSameRequestTasksPool:(HTURLSessionTask *)task;
@end

NS_ASSUME_NONNULL_END
