//
//  PTFileHandle.h
//  OAuthTest
//
//  Created by 彭平军 on 2017/5/4.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTFileHandle : NSObject

+ (BOOL)createTempFile; // 创建临时文件
+ (void)writeTempFileData:(NSData *)data; // 向临时文件写入数据
+ (NSData *)readTempFileDataWithOffset:(NSUInteger)offset andLength:(NSUInteger)length; // 读取临时文件数据
+ (void)cacheTempFileWithFileName:(NSString *)fileName; // 将临时文件保存到缓存文件夹
+ (NSString *)cacheFileExistsWithURL:(NSURL *)url; // 是否已经存在缓存文件，存在返回文件路径，不存在返回nil
+ (BOOL)clearCache;// 清理缓存文件

@end
