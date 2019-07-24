//
//  HTLRUManager.m
//  HttpToolDemo
//
//  Created by VinDiesel on 2019/7/24.
//  Copyright © 2019 jieyi. All rights reserved.
//

#import "HTLRUManager.h"

static HTLRUManager * manager = nil;

static NSMutableArray * operationQueue = nil;
static NSString * const HTLRUManagerName = @"HTLRUManagerName";

@implementation HTLRUManager
+ (HTLRUManager *)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[HTLRUManager alloc] init];
        }
        if ([[NSUserDefaults standardUserDefaults] objectForKey:HTLRUManagerName]) {
            operationQueue = [NSMutableArray arrayWithArray:(NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:HTLRUManagerName]];
        }else{
            operationQueue = [NSMutableArray array];
        }
    });
    return manager;
}
- (void)addFileNode:(NSString *)filename {
    NSArray *array = [operationQueue copy];
    
    //优化遍历
    NSArray *reverseArray = [[array reverseObjectEnumerator] allObjects];
    [reverseArray enumerateObjectsUsingBlock:^(NSDictionary*obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj[@"fileName"] isEqualToString:filename]) {
            [operationQueue removeObjectAtIndex:idx];
            *stop = YES;
        }
    }];
    NSDate * date = [NSDate date];
    NSDictionary *newDic = @{@"fileName":filename,@"date":date};
    [operationQueue addObject:newDic];
    [[NSUserDefaults standardUserDefaults] setObject:[operationQueue copy] forKey:HTLRUManagerName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)refreshIndexOfFileNode:(NSString *)filename {
    [self addFileNode:filename];
}
- (NSArray *)removeLRUFileNodeWithCacheTime:(NSTimeInterval)time {
    NSMutableArray *result = [NSMutableArray array];
    if (operationQueue.count > 0) {
        NSArray * tmpArray = [operationQueue copy];
        [tmpArray enumerateObjectsUsingBlock:^(NSDictionary * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDate * date = obj[@"date"];
            NSDate * newDate = [date dateByAddingTimeInterval:time];
            if ([[NSDate date] compare:newDate] == NSOrderedDescending) {
                [result addObject:obj[@"fileName"]];
                [operationQueue removeObjectAtIndex:idx];
            }
        }];
        if (result.count == 0) {
            NSString * removeFileName = [operationQueue firstObject][@"fileName"];
            [result addObject:removeFileName];
            [operationQueue removeObjectAtIndex:0];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[operationQueue copy] forKey:HTLRUManagerName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return [result copy];
}
- (NSArray *)currentQueue {
    return [operationQueue copy];
}
@end
