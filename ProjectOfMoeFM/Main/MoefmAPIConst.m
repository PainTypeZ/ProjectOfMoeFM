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
NSString * const MoePageValue = @"1";
NSString * const MoePerPageValue = @"20";// 只能设置20
NSString * const MoeObjTypeValue = @"song";
NSString * const MoeAPIValue = @"json";// 本工程全部使用JSON

/*  MoeFM API URL */
NSString * const MoeRadioListURL = @"http://api.moefou.org/wikis.json";// 电台列表

NSString * const MoeRadioSongsURL = @"http://api.moefou.org/radio/relationships.json";// 电台的歌曲列表, 主要是拿电台专辑的歌曲总数，注意某些wiki_id查询结果relationships可能是null

NSString * const MoeRadioPlayURL = @"http://moe.fm/listen/playlist";// 电台播放列表，可以作为标准电台播放列表使用，需要添加参数api=json;添加电台专辑wiki_id可以返回指定的电台专辑

/* MoeFM API response key */
NSString * const MoeResponseKey = @"response";

/* 封面 */
NSString * const MoeDefaultCoverURL = @"http://moe.fm/public/images/fm/cover_medium.png?v=";
NSString * const MoeCoverSizeSquareKey = @"square";

@end
