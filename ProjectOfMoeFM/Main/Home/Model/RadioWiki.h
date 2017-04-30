//
//  RadioWiki.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/12.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol RadioWiki;

@interface RadioWiki : JSONModel
// wikis = @[dict1, dict2, ...]
@property (copy, nonatomic) NSString *wiki_id;
@property (copy, nonatomic) NSString *wiki_title;
@property (copy, nonatomic) NSString *wiki_title_encode;
@property (copy, nonatomic) NSString *wiki_type;
@property (copy, nonatomic) NSString *wiki_date;
@property (copy, nonatomic) NSString *wiki_modified;
@property (copy, nonatomic) NSString <Optional>*fav_count;
@property (strong, nonatomic) NSArray <Optional>*wiki_meta;// @[@{meta_value, meta_key, meta_type}, @{meta_key, meta_type, meta_value = @{bg = @{url, color, position}}}];
@property (copy, nonatomic) NSString *wiki_fm_url;
@property (copy, nonatomic) NSString *wiki_url;
@property (strong, nonatomic) NSDictionary *wiki_cover;// @{small, medium, square, large};
@property (copy, nonatomic) NSString <Optional> *wiki_user_fav;
@end
