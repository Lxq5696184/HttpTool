//
//  HTMemoryCache.h
//  HttpToolDemo
//
//  Created by VinDiesel on 2019/7/24.
//  Copyright © 2019 jieyi. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  可拓展的内存缓存策略
 */
NS_ASSUME_NONNULL_BEGIN

@interface HTMemoryCache : NSObject
/**
 *  将数据写入内存
 *
 *  @param data 数据
 *  @param key  键值
 */
+ (void)writeData:(id)data forKey:(NSString *)key;

/**
 *  从内存中读取数据
 *
 *  @param  key  键值
 *  @return data 数据
 */
+ (id)readDataWithKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
