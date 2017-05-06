//
//  NSString+PTLoader.h
//  OAuthTest
//
//  Created by 彭平军 on 2017/5/4.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (PTLoader)

+ (NSString *)tempFilePath; // temp文件路径

+ (NSString *)cacheFolderPath; // cache文件夹路径

+ (NSString *)fileNameWithURL:(NSURL *)url; // 获取url中的文件名
@end
