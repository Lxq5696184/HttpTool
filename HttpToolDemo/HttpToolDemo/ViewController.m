//
//  ViewController.m
//  HttpToolDemo
//
//  Created by VinDiesel on 2019/7/24.
//  Copyright © 2019 jieyi. All rights reserved.
//

#import "ViewController.h"
#import "SHYJHttpTool.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self HttpRequest];
    // Do any additional setup after loading the view.
}
- (void)HttpRequest {
    NSString * url = @"http://news-at.zhihu.com/api/4/news/latest";
    [SHYJHttpTool configHttpHeader:@{}];
    [SHYJHttpTool getWithUrl:url refreshRequest:NO cache:NO params:@{} progressBlock:^(int64_t bytesRead, int64_t totalBytes) {
        NSLog(@"%lld -- %lld",bytesRead,totalBytes);
    } successBlock:^(id  _Nonnull response) {
        NSLog(@"成功 --- %@",response);
    } failBlock:^(NSError * _Nonnull error) {
        NSLog(@"失败 --- %@",error);
    }];
    NSLog(@"size is %lu",[SHYJHttpTool totalCacheSize]);
}

@end
