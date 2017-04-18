//
//  SongFavSub.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/17.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface SongFavSub : JSONModel
@property (copy, nonatomic) NSString <Optional> *fav_id;
@property (copy, nonatomic) NSString <Optional> *fav_obj_id;
@property (copy, nonatomic) NSString <Optional> *fav_obj_type;
@property (copy, nonatomic) NSString <Optional> *fav_uid;
@property (copy, nonatomic) NSString <Optional> *fav_date;
@property (copy, nonatomic) NSString <Optional> *fav_type;
@end
