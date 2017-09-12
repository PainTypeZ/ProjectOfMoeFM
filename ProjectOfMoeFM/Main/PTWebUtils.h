//
//  PTWebUtils.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/9.
//  Copyright © 2017年 彭平军. All rights reserved.
//

// 回调
typedef void(^callback)(id object);
// 错误信息
typedef void(^error)(id error);

#import <Foundation/Foundation.h>

@interface PTWebUtils : NSObject

// 请求电台列表信息
+ (void)requestRadioListInfoWithPage:(NSUInteger)currentPage perpage:(NSUInteger)perpageNumber completionHandler:(callback)callback errorHandler:(error)errorHandler;
// 请求热门电台列表
+ (void)requestHotRadiosWithCompletionHandler:(callback)callback errorHandler:(error)errorHandler;

// 请求电台条目信息,可以拿到电台songcount。。。
+ (void)requestRadioSongCountWithRadioId:(NSString *)radioId completionHandler:(callback)callback errorHandler:(error)errorHandler;

// 请求电台播放列表，需要radio = wiki_id参数，第几页page，每页多少歌曲数量perpage，注意最后一页返回的结果可能不够perpage数量;此请求也可以返回随机的收藏歌曲播放列表
+ (void)requestPlaylistWithRadioId:(NSString *)RadioId page:(NSUInteger)page perpage:(NSUInteger)perpage completionHandler:(callback)callback errorHandler:(error)errorHandler;

// 请求专辑列表信息
+ (void)requestAlbumListInfoWithPage:(NSUInteger)currentPage perpage:(NSUInteger)perpageNumber completionHandler:(callback)callback errorHandler:(error)errorHandler;

// 请求最新专辑列表
+ (void)requestLatestAlbumWithCompletionHandler:(callback)callback errorHandler:(error)errorHandler;

// 请求专辑条目信息,可以拿到专辑songcount。。。
+ (void)requestAlbumSongCountWithAlbumID:(NSString *)albumID completionHandler:(callback)callback errorHandler:(error)errorHandler;

// 请求专辑播放列表，需要music = wiki_id参数，第几页page，每页多少歌曲数量perpage，注意最后一页返回的结果可能不够perpage数量;此请求也可以返回随机的收藏歌曲播放列表
+ (void)requestPlaylistWithAlbumID:(NSString *)albumID page:(NSUInteger)page perpage:(NSUInteger)perpage completionHandler:(callback)callback errorHandler:(error)errorHandler;

// 以SongIDs请求播放列表，收藏曲目的顺序播放列表和单曲必须使用的方法
+ (void)requestPlaylistWithSongIDs:(NSArray <NSString *> *)SongIDs completionHandler:(callback)callback errorHandler:(error)errorHandler;

// 请求默认随机播放列表
+ (void)requestRandomPlaylistWithCompletionHandler:(callback)callback errorHandler:(error)errorHandler;

// 请求收藏曲目的随机播放列表
+ (void)requestFavRandomPlaylistWithCompletionHandler:(callback)callback errorHandler:(error)errorHandler;

// 请求收藏歌曲列表（obj_type = song), 只能拿到收藏曲目的wiki_id数组, 其结果用于请求收藏曲目顺序播放列表和完整的收藏曲目信息;OAuth限定
+ (void)requestFavSongListWithPage:(NSUInteger)page perpage:(NSUInteger)perpage completionHandler:(callback)callback errorHandler:(error)errorHandler;

// 添加或者删除收藏
+ (void)requestUpdateToAddOrDelete:(NSString *)addOrDelete objectType:(NSString *)fav_obj_type objectID:(NSString *)fav_obj_id completionHandler:(callback)callback errorHandler:(error)errorHandler;

// 获取OAuth登录的用户信息，也是用来检查登录状态的方法
+ (void)requestUserInfoWithCompletionHandler:(callback)callback errorHandler:(error)errorHandler;

@end
