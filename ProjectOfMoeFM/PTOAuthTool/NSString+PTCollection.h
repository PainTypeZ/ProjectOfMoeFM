//
//  NSString+PTCollection.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/10.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
@interface NSString (PTCollection)

/* PTOAuthTool相关*/

// URL编码，9.0之前使用此方法，9.0之后使用原生方法
+ (NSString *)urlEncodeString:(NSString *)string;
// Base64 + HAMC-SHA1加密
+ (NSString *)base64_HMAC_SHA1:(NSString *)key string:(NSString *)string;
// 升序排列get请求参数
+ (NSString *)ascendingOrderGETRequesetParamsDictionary:(NSDictionary *)params;


/* 文件操作相关 */

// 临时文件路径
+ (NSString *)tempFilePath;
// 缓存文件夹路径
+ (NSString *)cacheFolderPath;
// 获取网址中的文件名
+ (NSString *)fileNameWithURL:(NSURL *)url;

@end
