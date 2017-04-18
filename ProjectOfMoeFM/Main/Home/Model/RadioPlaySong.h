//
//  RadioPlaySong.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/13.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "SongFavSub.h"
@protocol RadioPlaySong;

@interface RadioPlaySong : JSONModel

@property (copy, nonatomic) NSString *up_id;
@property (copy, nonatomic) NSString *url;// 播放地址
@property (copy, nonatomic) NSString *stream_length;
@property (copy, nonatomic) NSString *stream_time;
@property (copy, nonatomic) NSString *file_type;
@property (copy, nonatomic) NSString *wiki_id;
@property (copy, nonatomic) NSString *wiki_type;
@property (copy, nonatomic) NSDictionary *cover;// @{small, medium, square, large};
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *wiki_title;
@property (copy, nonatomic) NSString *wiki_url;
@property (copy, nonatomic) NSString <Optional> *sub_id;
@property (copy, nonatomic) NSString <Optional> *sub_type;
@property (copy, nonatomic) NSString <Optional> *sub_title;
@property (copy, nonatomic) NSString <Optional> *sub_url;
@property (copy, nonatomic) NSString <Optional> *artist;
@property (copy, nonatomic) NSString <Optional> *fav_wiki;
@property (strong, nonatomic) SongFavSub <Optional> *fav_sub;

@end
