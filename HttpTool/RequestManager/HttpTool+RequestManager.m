//
//  HttpTool+RequestManager.m
//  HttpToolDemo
//
//  Created by VinDiesel on 2019/7/24.
//  Copyright © 2019 jieyi. All rights reserved.
//

#import "HttpTool+RequestManager.h"
@interface NSURLRequest (decide)

//判断是否是同一个请求(依据是请求的url和参数是否相同)
- (BOOL)isTheSameRequest:(NSURLRequest *)request;
@end
@implementation NSURLRequest (decide)

- (BOOL)isTheSameRequest:(NSURLRequest *)request {
    if ([self.HTTPMethod isEqualToString:request.HTTPMethod]) {
        if ([self.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
            if ([self.HTTPMethod isEqualToString:@"GET"] || [self.HTTPBody isEqualToData:request.HTTPBody]) {
                return YES;
            }
        }
    }
    return NO;
}
@end

@implementation HttpTool (RequestManager)
+ (BOOL)haveSameRequestInTasksPool:(HTURLSessionTask *)task {
    __block BOOL isSame = NO;
    [[self currentRunningTasks] enumerateObjectsUsingBlock:^(HTURLSessionTask * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([task.originalRequest isTheSameRequest:obj.originalRequest]) {
            isSame = YES;
            *stop = YES;
        }
    }];
    return isSame;
}
+ (HTURLSessionTask *)cancelSameRequestTasksPool:(HTURLSessionTask *)task {
    __block HTURLSessionTask * oldTask = nil;
    [[self currentRunningTasks] enumerateObjectsUsingBlock:^(HTURLSessionTask * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([task.originalRequest isTheSameRequest:obj.originalRequest]) {
            if (obj.state == NSURLSessionTaskStateRunning) {
                [obj cancel];
                oldTask = obj;
            }
            *stop = YES;
        }
    }];
    return oldTask;
}

@end
