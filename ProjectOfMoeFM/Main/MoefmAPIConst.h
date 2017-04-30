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
extern NSString * const MoeAPIKey;
extern NSString * const MoeRadioPlayListKey;

/* MoeFM API value */
extern NSString * const MoeWikiTypeValue;
//extern NSString * const MoePageValue;
extern NSString * const MoePerPageValue;// 使用默认值9，不然有BUG
extern NSString * const MoeObjTypeValue;
extern NSString * const MoeAPIValue;// 本工程全部使用JSON

/*  MoeFM API URL */
extern NSString * const MoeRadioListURL;// 电台列表

extern NSString * const MoeRadioSongsURL;// 电台的歌曲列表, 主要是拿电台专辑的歌曲总数，似乎不能用，很多wiki_id查询结果是null

extern NSString * const MoeRadioPlayURL;// 电台播放列表，可以作为标准电台播放列表使用，需要添加参数api=json;添加电台专辑wiki_id可以返回指定的电台专辑

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

@end
