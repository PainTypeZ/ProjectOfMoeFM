//
//  PTFileHandle.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/5.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "PTFileHandle.h"
#import "NSString+PTCollection.h"

@implementation PTFileHandle
// 创建临时文件
+ (BOOL)createTempFile {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [NSString tempFilePath];
    if ([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path error:nil];
    }
    return [manager createFileAtPath:path contents:nil attributes:nil];
}
// 向临时文件写入数据
+ (void)writeTempFileData:(NSData *)data {
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:[NSString tempFilePath]];
    [handle seekToEndOfFile];
    [handle writeData:data];
}
// 读取临时文件数据
+ (NSData *)readTempFileDataWithOffset:(NSUInteger)offset length:(NSUInteger)length {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:[NSString tempFilePath]];
    [handle seekToFileOffset:offset];
    return [handle readDataOfLength:length];
}
// 保存临时文件到缓存文件夹
+ (void)cacheTempFileWithFileName:(NSString *)name {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *cacheFolderPath = [NSString cacheFolderPath];
    if ([manager fileExistsAtPath:cacheFolderPath] == NO) {
        [manager createDirectoryAtPath:cacheFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *cacheFilePath = [NSString stringWithFormat:@"%@/%@", cacheFolderPath, name];
    BOOL isSuccess = [[NSFileManager defaultManager] copyItemAtPath:[NSString tempFilePath] toPath:cacheFilePath error:nil];
    NSLog(@"cache file : %@", isSuccess ? @"Success" : @"Fail");
}
// 是否存在缓存文件 ? 返回文件路径 : 返回nil
+ (NSString *)cacheFileExistsWithURL:(NSURL *)url {
    NSString *cacheFilePath = [NSString stringWithFormat:@"%@/%@", [NSString cacheFolderPath], [NSString fileNameWithURL:url]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath] == YES) {
        return cacheFilePath;
    }
    return nil;
}
// 清理缓存文件
+ (BOOL)cleanCache {
    NSFileManager *manager = [NSFileManager defaultManager];
    return [manager removeItemAtPath:[NSString cacheFolderPath] error:nil];
}

@end
