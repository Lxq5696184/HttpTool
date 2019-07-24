//
//  HTDiskCache.m
//  HttpToolDemo
//
//  Created by VinDiesel on 2019/7/24.
//  Copyright © 2019 jieyi. All rights reserved.
//

#import "HTDiskCache.h"

@implementation HTDiskCache
+ (void)writeData:(id)data toDir:(NSString *)directory filename:(NSString *)filename {
    assert(data);
    assert(directory);
    assert(filename);
    NSError * error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (error) {
        NSLog(@"createDirectory error is %@",error.localizedDescription);
        return;
    }
    NSString * filePath = [directory stringByAppendingPathComponent:filename];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
}
+ (id)readDataFormDir:(NSString *)directory filename:(NSString *)filename {
    assert(directory);
    assert(filename);
    NSData *data = nil;
    NSString * filePath = [directory stringByAppendingPathComponent:filename];
    data = [[NSFileManager defaultManager] contentsAtPath:filePath];
    return data;
}
+ (NSUInteger)dataSizeInDir:(NSString *)directory {
    if (!directory) {
        return 0;
    }
    BOOL isDir = NO;
    NSUInteger total = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDir]) {
        NSError * error = nil;
        NSArray * array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:&error];
        if (!error) {
            for (NSString * subFile in array) {
                NSString * filePath = [directory stringByAppendingPathComponent:subFile];
                NSDictionary * attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
                if (!error) {
                    total += [attributes[NSFileSize] unsignedIntegerValue];
                }
            }
        }
    }
    return total;
}
+ (void)clearDataDir:(NSString *)directory {
    if (directory) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:nil]) {
            NSError * error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:directory error:&error];
            if (error) {
                NSLog(@"清理缓存是出现错误：%@",error.localizedDescription);
            }
        }
    }
}
+ (void)deleteCache:(NSString *)fileUrl {
    if (fileUrl) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileUrl isDirectory:nil]) {
            NSError * error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:fileUrl error:&error];
            if (error) {
                NSLog(@"删除文件出现错误:%@",error.localizedDescription);
            }
        }else{
            NSLog(@"文件不存在");
        }
    }
}
@end
