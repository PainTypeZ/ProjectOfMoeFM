//
//  MoefmFavObject.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/9/10.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "MoefmWiki.h"
#import "MoefmFavSubUpload.h"

@interface MoefmFavObject : JSONModel

@property (copy, nonatomic) NSString *sub_id;
@property (copy, nonatomic) NSString *sub_title;
@property (copy, nonatomic) NSString *sub_view_title;
@property (strong, nonatomic) MoefmWiki *wiki;
@property (strong, nonatomic) NSArray <MoefmFavSubUpload> *sub_upload;
@property (strong, nonatomic) NSArray <Optional> *sub_meta;

@end
