//
//  PTFileHandle.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/5.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTFileHandle : NSObject

// 创建临时文件
+ (BOOL)createTempFile;
// 向临时文件写入数据
+ (void)writeTempFileData:(NSData *)data;
// 读取临时文件数据
+ (NSData *)readTempFileDataWithOffset:(NSUInteger)offset length:(NSUInteger)length;
// 保存临时文件到缓存文件夹
+ (void)cacheTempFileWithFileName:(NSString *)name;
// 是否存在缓存文件 ? 返回文件路径 : 返回nil
+ (NSString *)cacheFileExistsWithURL:(NSURL *)url;
// 清理缓存文件
+ (BOOL)cleanCache;

@end
