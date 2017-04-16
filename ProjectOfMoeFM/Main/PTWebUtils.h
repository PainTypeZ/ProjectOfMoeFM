//
//  PTWebUtils.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/9.
//  Copyright © 2017年 彭平军. All rights reserved.
//

// 回调
typedef void(^callback)(id object);
// 异常处理
typedef void(^error)(id error);
#import <Foundation/Foundation.h>

@interface PTWebUtils : NSObject

// 请求电台列表信息
+ (void)requestRadioListInfoWithCompletionHandler:(callback)callback errorHandler:(error)errorHandler;
// 请求某个电台专辑的歌曲列表信息，除了获取歌曲总数外，大概是没其他用的接口。。。
+ (void)requestRadioSongsInfoWithWiki_id:(NSString *)wiki_id CompletionHandler:(callback)callback errorHandler:(error)errorHandler;
// 请求电台播放列表，需要radio = wiki_id参数, 若填写参数为nil，则返回随机列表,只返回第1页，9首歌曲
//+ (void)requestRadioPlayListWithRadio_id:(NSString *)radio_id CompletionHandler:(callback)callback errorHandler:(error)errorHandler;

// 请求电台播放列表，需要radio = wiki_id参数，第几页page，每页多少歌曲数量perpage，注意最后一页返回的结果可能不够perpage数量
+ (void)requestRadioPlayListWithRadio_id:(NSString *)radio_id andPage:(NSString *)page andPerpage:(NSString *)perpage CompletionHandler:(callback)callback errorHandler:(error)errorHandler;

@end
