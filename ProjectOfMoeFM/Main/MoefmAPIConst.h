//
//  MoefmAPIConst.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/13.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoefmAPIConst : NSObject

/* MoeFM API key */
extern NSString * const MoeWikiTypeKey;
extern NSString * const MoePageKey;
extern NSString * const MoePerPageKey;
extern NSString * const MoeWikiIdKey;
extern NSString * const MoeObjTypeKey;
extern NSString * const MoeAPIKey;// api = json, 不是consumer key
extern NSString * const MoeRadioPlayListKey;

/* MoeFM API value */
extern NSString * const MoeWikiTypeValue;
//extern NSString * const MoePageValue;
extern NSString * const MoePerPageValue;// 使用默认值9，不然有BUG
extern NSString * const MoeObjTypeValue;
extern NSString * const MoeAPIValue;// 本工程全部使用JSON

/*  MoeFM API URL */
extern NSString * const MoeRadioListURL;// 电台列表

extern NSString * const MoeHotRadiosURL;// 热门电台，参数api=json，hot_radios=1; api_key(未授权OAuth的时候启用)

extern NSString * const MoeRadioSongCountURL;// 电台的歌曲列表, 主要是拿电台专辑的歌曲总数，似乎不能用，很多wiki_id查询结果是null

extern NSString * const MoeRadioPlayURL;// 电台播放列表，可以作为标准电台播放列表使用，需要添加参数api=json;添加电台专辑wiki_id可以返回指定的电台专辑;同时也是随机收藏列表的接口

extern NSString * const MoeFavSongsURL;// 收藏歌曲列表（非随机）

extern NSString * const MoeAddFavURL;// 添加收藏，参数fav_obj_type，fav_obj_id，fav_type

extern NSString * const MoeDeleteFavURL;// 取消收藏，参数fav_obj_type，fav_obj_id

extern NSString * const MoeUserInfoURL;// 查询用户信息(OAuth方式)
/* MoeFM API response key */
extern NSString * const MoeResponseKey;

/* 封面 */
extern NSString * const MoeDefaultPictureURL;
extern NSString * const MoePictureSizeSquareKey;
extern NSString * const MoePictureSizeMediumKey;
extern NSString * const MoePictureSizeLargeKey;

/* callbackDictkey */
extern NSString * const MoeCallbackDictRadioKey; // 电台
extern NSString * const MoeCallbackDictSongKey; // 歌曲
extern NSString * const MoeCallbackDictSongIDKey; // 歌曲ID
extern NSString * const MoeCallbackDictCountKey; // 条目总数
extern NSString * const MoeCallbackDictRelationshipsKey; //电台歌曲条目信息
extern NSString * const MoeCallbackDictFavsKey;// 收藏的条目数组
/* playType */
extern NSString * const MoeSingleSongPlay;
extern NSString * const MoeRandomPlay;
extern NSString * const MoeFavRandomPlay;
//extern NSString * const MoeOrderedFavList;

@end
