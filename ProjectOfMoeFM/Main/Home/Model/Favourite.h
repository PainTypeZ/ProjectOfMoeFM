//
//  Favourite.h
//  ProjectOfMoeFM
//
//  Created by 彭平军 on 2017/4/18.
//  Copyright © 2017年 彭平军. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "FavObject.h"

@protocol Favourite;

@interface Favourite : JSONModel

@property (copy, nonatomic) NSString *fav_id;
@property (copy, nonatomic) NSString *fav_obj_id;
@property (copy, nonatomic) NSString *fav_obj_type;
@property (copy, nonatomic) NSString *fav_uid;
@property (copy, nonatomic) NSString *fav_date;
@property (copy, nonatomic) NSString *fav_type;
@property (strong, nonatomic) FavObject *obj;

@end
