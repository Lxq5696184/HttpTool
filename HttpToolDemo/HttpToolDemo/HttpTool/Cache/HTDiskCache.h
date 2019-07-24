//
//  HTDiskCache.h
//  HttpToolDemo
//
//  Created by VinDiesel on 2019/7/24.
//  Copyright © 2019 jieyi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTDiskCache : NSObject
/**
 *  将数据写入磁盘
 *
 *  @param  data      数据
 *  @param  directory 目录
 *  @param  filename  文件名
 */
+ (void)writeData:(id)data
            toDir:(NSString *)directory
         filename:(NSString *)filename;

/**
 *  从磁盘读取数据
 *
 *  @param  directory   目录
 *  @param  filename    文件名
 *
 *  @return data        数据
 */
+ (id)readDataFormDir:(NSString *)directory
             filename:(NSString *)filename;

/**
 *  获取目录中文件总大小
 *
 *  @param  directory  目录
 *
 *  @return  文件大小
 */
+ (NSUInteger)dataSizeInDir:(NSString *)directory;
/**
 *  清理目录中的文件
 *
 *  @param directory  目录
 *
 */
+ (void)clearDataDir:(NSString *)directory;
/**
 *  删除某个文件
 *
 *  @param fileUrl  文件路径
 */
+ (void)deleteCache:(NSString *)fileUrl;
@end

NS_ASSUME_NONNULL_END
