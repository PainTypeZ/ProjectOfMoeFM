//
//  MoefmObject.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/10.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "MoefmSubUpload.h"

@protocol MoefmObject;

@interface MoefmObject : JSONModel

@property (copy, nonatomic) NSString *sub_id;
@property (copy, nonatomic) NSString *sub_parent_wiki;
@property (copy, nonatomic) NSString *sub_parent;
@property (copy, nonatomic) NSString *sub_title;
@property (copy, nonatomic) NSString *sub_title_encode;
@property (copy, nonatomic) NSString *sub_type;
@property (copy, nonatomic) NSString *sub_order;
@property (strong, nonatomic) NSDictionary <Optional> *sub_meta;
@property (copy, nonatomic) NSString <Optional> *sub_about;
@property (copy, nonatomic) NSString *sub_comment_count;
@property (copy, nonatomic) NSString <Optional> *sub_data;
@property (copy, nonatomic) NSString *sub_date;
@property (copy, nonatomic) NSString *sub_modified;
@property (copy, nonatomic) NSString *sub_url;
@property (copy, nonatomic) NSString *sub_fm_url;
@property (copy, nonatomic) NSString *sub_view_title;
@property (strong, nonatomic) NSArray <MoefmSubUpload> *sub_upload;

@end
