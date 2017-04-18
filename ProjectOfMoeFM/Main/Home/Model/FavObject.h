//
//  FavObject.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/18.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "RadioWiki.h"
#import "SubUpload.h"

@interface FavObject : JSONModel

@property (copy, nonatomic) NSString *sub_id;
@property (copy, nonatomic) NSString *sub_view_title;
@property (strong, nonatomic) RadioWiki *wiki;
@property (strong, nonatomic) NSArray<SubUpload> *sub_upload;

@end
