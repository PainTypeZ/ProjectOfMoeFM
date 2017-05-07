//
//  MoefmAPIConst.m
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/13.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import "MoefmAPIConst.h"

@implementation MoefmAPIConst

/* MoeFM API key */
NSString * const MoeWikiTypeKey = @"wiki_type";
NSString * const MoePageKey = @"page";
NSString * const MoePerPageKey = @"perpage";
NSString * const MoeWikiIdKey = @"wiki_id";
NSString * const MoeObjTypeKey = @"obj_type";
NSString * const MoeAPIKey = @"api";
NSString * const MoeRadioPlayListKey = @"radio";

/* MoeFM API value */
NSString * const MoeWikiTypeValue = @"radio";
//NSString * const MoePageValue = @"1";
NSString * const MoePerPageValue = @"9";// 使用默认值9，不然bug很多
NSString * const MoeObjTypeValue = @"song";
NSString * const MoeAPIValue = @"json";// 本工程全部使用JSON

/*  MoeFM API URL */
NSString * const MoeRadioListURL = @"http://api.moefou.org/wikis.json";// 电台列表

NSString * const MoeRadioSongCountURL = @"http://api.moefou.org/radio/relationships.json";// 电台的歌曲列表, 主要是拿电台专辑的歌曲总数，注意某些wiki_id查询结果relationships可能是null

NSString * const MoeRadioPlayURL = @"http://moe.fm/listen/playlist";// 电台播放列表，可以作为标准电台播放列表使用，需要添加参数api=json;添加电台专辑wiki_id可以返回指定的电台专辑
NSString * const MoeFavSongsURL = @"http://api.moefou.org/user/favs/sub.json";// 收藏歌曲列表（非随机）

NSString * const MoeAddFavURL = @"http://api.moefou.org/fav/add.json";// 添加收藏，参数fav_obj_type，fav_obj_id，fav_type
NSString * const MoeDeleteFavURL = @"http://api.moefou.org/fav/delete.json";// 取消收藏，参数fav_obj_type，fav_obj_id
NSString * const MoeUserInfoURL = @"http://api.moefou.org/user/detail.json";// 查询用户信息(OAuth方式)
NSString * const MoeHotRadiosURL = @"http://moe.fm/explore";// 热门电台，参数api=json，hot_radios=1; api_key(未授权OAuth的时候启用)
/* MoeFM API response key */
NSString * const MoeResponseKey = @"response";

/* 封面 */
NSString * const MoeDefaultPictureURL = @"http://moe.fm/public/images/fm/cover_medium.png?v=";
NSString * const MoePictureSizeMediumKey = @"medium";// 中等大小
NSString * const MoePictureSizeSquareKey = @"square";// 方形图
NSString * const MoePictureSizeLargeKey = @"large";// 最大

/* callbackDictkey */
NSString * const MoeCallbackDictRadioKey = @"radios"; // 电台
NSString * const MoeCallbackDictSongKey = @"songs"; // 歌曲
NSString * const MoeCallbackDictSongIDKey = @"songIDs"; // 歌曲ID
NSString * const MoeCallbackDictCountKey = @"count"; // 条目总数

/* playType */
NSString * const MoeSingleSong = @"singleSong";
NSString * const MoeRandomList = @"random";
NSString * const MoeFavRandomList = @"favRandom";
NSString * const MoeOrderedFavList = @"favOrdered";

@end
