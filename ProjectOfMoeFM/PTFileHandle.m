//
//  PTFileHandle.m
//  OAuthTest
//
//  Created by 彭平军 on 2017/5/4.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "PTFileHandle.h"
#import "NSString+PTLoader.h"
@implementation PTFileHandle

+ (BOOL)createTempFile {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [NSString tempFilePath];
    if ([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path error:nil];
    }
    return [manager createFileAtPath:path contents:nil attributes:nil];
}

+ (void)writeTempFileData:(NSData *)data {
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:[NSString tempFilePath]];
    [handle seekToEndOfFile];
    [handle writeData:data];
}

+ (NSData *)readTempFileDataWithOffset:(NSUInteger)offset andLength:(NSUInteger)length {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:[NSString tempFilePath]];
    [handle seekToFileOffset:offset];
    return [handle readDataOfLength:length];
}

+ (void)cacheTempFileWithFileName:(NSString *)fileName {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *cacheFolderPath = [NSString cacheFolderPath];
    if (![manager fileExistsAtPath:cacheFolderPath]) {
        [manager createDirectoryAtPath:cacheFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *cacheFilePath = [cacheFolderPath stringByAppendingPathComponent:fileName];
    BOOL success = [manager copyItemAtPath:[NSString tempFilePath] toPath:cacheFilePath error:nil];
    NSLog(@"cache file : %@", success ? @"success" : @"fail");
}

+ (NSString *)cacheFileExistsWithURL:(NSURL *)url {
    NSString *cacheFilePath = [[NSString cacheFolderPath] stringByAppendingPathComponent:[NSString fileNameWithURL:url]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        return cacheFilePath;
    }
    return nil;
}

+ (BOOL)clearCache {
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL success = [manager removeItemAtPath:[NSString cacheFolderPath] error:nil];
    return success;
}

@end
